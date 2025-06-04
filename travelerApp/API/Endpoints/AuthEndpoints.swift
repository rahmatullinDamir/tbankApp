import Foundation
import Alamofire

enum AuthEndpoints {
    case login(LoginDto)
    case register(RegistrationFormDto)
    case refreshToken
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
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        case .refreshToken:
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
        }
    }
} 