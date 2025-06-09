import Foundation
import Alamofire

enum AuthEndpoints {
    case login(LoginDto)
    case register(RegistrationFormDto)
    case refreshToken(String)
    case getUsersByPhoneNumbers([String])
}

extension AuthEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .login:
            return NetworkConstants.apiPath + "/user/login"
        case .register:
            return NetworkConstants.apiPath + "/user"
        case .refreshToken:
            return NetworkConstants.apiPath + "/refresh"
        case .getUsersByPhoneNumbers:
            return NetworkConstants.apiPath + "/user/byPhoneNumber"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken:
            return .post
        case .getUsersByPhoneNumbers:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let request):
            return try? request.asDictionary()
        case .register(let request):
            return try? request.asDictionary()
        case .refreshToken:
            return nil
        case .getUsersByPhoneNumbers(let phoneNumbers):
            return ["phoneNumbers": phoneNumbers]
        }
    }
    
    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(.contentType("application/json"))
        headers.add(.accept("application/json"))
        
        switch self {
        case .refreshToken(let refreshToken):
            headers.add(.authorization(bearerToken: refreshToken))
        default:
            if let accessToken = KeychainManager.shared.getAccessToken() {
                headers.add(.authorization(bearerToken: accessToken))
            }
        }
        
        return headers
    }
} 
