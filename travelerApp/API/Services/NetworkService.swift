import Foundation
import Alamofire

protocol NetworkServicing {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws
}

final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    private let session: Session
    private let keychainManager: KeychainManager
    private let authService: AuthServicing?
    private var isRefreshing = false
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = Session(configuration: configuration)
        self.keychainManager = .shared
        self.authService = nil
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        do {
            return try await performRequest(endpoint)
        } catch NetworkError.unauthorized {
            try await refreshTokenIfNeeded()
            return try await performRequest(endpoint)
        }
    }
    
    func request(_ endpoint: APIEndpoint) async throws {
        do {
            try await performRequestWithoutResponse(endpoint)
        } catch NetworkError.unauthorized {
            try await refreshTokenIfNeeded()
            try await performRequestWithoutResponse(endpoint)
        }
    }
    
    private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error, response: response.response))
                }
            }
        }
    }
    
    private func performRequestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .response { response in
                if let error = response.error {
                    continuation.resume(throwing: self.handleError(error, response: response.response))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard !isRefreshing else {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return
        }
        
        guard let refreshToken = keychainManager.getRefreshToken() else {
            throw NetworkError.unauthorized
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            let authService = AuthService() 
            let tokens = try await authService.refreshToken()
            keychainManager.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        } catch {
            keychainManager.removeTokens()
            throw NetworkError.unauthorized
        }
    }
    
    private func handleError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError
            default:
                break
            }
        }
        
        switch error {
        case .responseValidationFailed(reason: .dataFileNil),
             .responseValidationFailed(reason: .dataFileReadFailed),
             .responseSerializationFailed(reason: .inputFileNil),
             .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
            return .noData
        case .responseSerializationFailed(reason: .jsonSerializationFailed),
             .responseSerializationFailed(reason: .decodingFailed):
            return .decodingError
        default:
            return .unknown(error)
        }
    }
} 
