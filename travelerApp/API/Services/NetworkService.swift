import Foundation
import Alamofire

protocol NetworkServicing {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws
}

@globalActor actor NetworkActor {
    static let shared = NetworkActor()
}

@NetworkActor
final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    private let session: Session
    private let keychainManager: KeychainManager
    private let reachabilityManager: NetworkReachabilityManager
    private var refreshTask: Task<Void, Error>?
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = Session(configuration: configuration)
        self.keychainManager = .shared
        self.reachabilityManager = .shared
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard reachabilityManager.isConnected else {
            throw NetworkError.noInternet
        }
        
        do {
            return try await performRequest(endpoint)
        } catch NetworkError.unauthorized {
            try await refreshTokenIfNeeded()
            return try await performRequest(endpoint)
        }
    }
    
    func request(_ endpoint: APIEndpoint) async throws {
        guard reachabilityManager.isConnected else {
            throw NetworkError.noInternet
        }
        
        do {
            try await performRequestWithoutResponse(endpoint)
        } catch NetworkError.unauthorized {
            try await refreshTokenIfNeeded()
            try await performRequestWithoutResponse(endpoint)
        }
    }
    
    private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            
            request.validate()
                .responseData { [weak self] response in
                    guard let self = self else { return }
                    switch response.result {
                    case .success(let data):
                        do {
                            
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .custom { decoder in
                                let container = try decoder.singleValueContainer()
                                let dateString = try container.decode(String.self)
                                
                                if let date = Date.apiDateFormatter.date(from: dateString) {
                                    return date
                                }
                                
                                if let date = ISO8601DateFormatter().date(from: dateString) {
                                    return date
                                }
                                
                                throw DecodingError.dataCorruptedError(
                                    in: container,
                                    debugDescription: "Cannot decode date string \(dateString)"
                                )
                            }
                            
                            let decoded = try decoder.decode(T.self, from: data)
                            continuation.resume(returning: decoded)
                        } catch {
                            continuation.resume(throwing: NetworkError.decodingError)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    private func performRequestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            
            request.validate()
                .response { [weak self] response in
                    guard let self = self else { return }
                    if let error = response.error {
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    } else {
                        continuation.resume()
                    }
                }
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        guard let refreshToken = keychainManager.getRefreshToken() else {
            throw NetworkError.unauthorized
        }
        
        let task = Task {
            do {
                let endpoint = AuthEndpoints.refreshToken(refreshToken)
                let tokens: JwtTokenPairDto = try await performRequest(endpoint)
                keychainManager.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
            } catch {
                keychainManager.removeTokens()
                throw NetworkError.unauthorized
            }
        }
        
        refreshTask = task
        defer { refreshTask = nil }
        
        try await task.value
    }
    
    private func handleError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 500...599: return .serverError
            default: break
            }
        }
        
        if let underlyingError = error.underlyingError as? URLError {
            switch underlyingError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                return .noInternet
            case .timedOut:
                return .networkTimeout
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
