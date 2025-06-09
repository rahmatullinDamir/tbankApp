import Foundation
import Alamofire

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders { get }
    var url: URL { get }
}

extension APIEndpoint {
    var baseURL: String {
        return NetworkConstants.baseURL
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.queryString
        case .patch:
            return CustomJSONEncoding(withJSONObject: parameters ?? [:])
        default:
            return Alamofire.JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let accessToken = KeychainManager.shared.getAccessToken(),
           !(self is AuthEndpoints) || method != .post {
            headers.add(.authorization(bearerToken: accessToken))
        }
        
        return headers
    }
    
    var url: URL {
        guard let url = URL(string: NetworkConstants.baseURL)?.appendingPathComponent(path) else {
            fatalError("Could not create URL for path: \(path)")
        }
        return url
    }
} 
