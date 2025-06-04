import Foundation

enum NetworkConstants {
    static let baseURL = "http://localhost:8080"
    static let apiPath = "/api/v1"
    static let defaultHeaders: [String: String] = [
        "Content-Type": ContentType.json,
        "Accept": ContentType.json
    ]
    
    enum HTTPHeaderField {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let acceptType = "Accept"
        static let acceptEncoding = "Accept-Encoding"
    }
    
    enum ContentType {
        static let json = "application/json"
    }
} 
