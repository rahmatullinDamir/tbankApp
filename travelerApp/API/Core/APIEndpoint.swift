import Foundation
import Alamofire

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

extension APIEndpoint {
    var baseURL: String {
        return NetworkConstants.baseURL
    }
    
    var url: String {
        return baseURL + path
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = KeychainManager.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
} 