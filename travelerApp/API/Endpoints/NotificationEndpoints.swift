import Alamofire
import Foundation

enum NotificationEndpoints: APIEndpoint {
    case getNotifications(isRead: Bool)
    case markAsRead([Int64])
    case handleInvitation(tripId: Int64, accept: Bool)
    
    var path: String {
        switch self {
        case .getNotifications:
            return NetworkConstants.apiPath + "/me/notification"
        case .markAsRead:
            return NetworkConstants.apiPath + "/me/notification"
        case .handleInvitation(let tripId, _):
            return NetworkConstants.apiPath + "/trip/\(tripId)/participants/invitation"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getNotifications:
            return .get
        case .markAsRead:
            return .patch
        case .handleInvitation:
            return .patch
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getNotifications(let isRead):
            return ["isRead": isRead]
        case .markAsRead(let ids):
            return ["notificationIdList": ids]
        case .handleInvitation(_, let accept):
            return ["invitation": accept]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getNotifications:
            return URLEncoding.queryString
        case .markAsRead:
            return CustomJSONEncoding(withJSONObject: parameters ?? [:])
        case .handleInvitation:
            return URLEncoding.queryString
        }
    }
}

struct CustomJSONEncoding: ParameterEncoding {
    private let jsonObject: Any
    
    init(withJSONObject object: Any) {
        self.jsonObject = object
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        request.httpBody = data
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}
