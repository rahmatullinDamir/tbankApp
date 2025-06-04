import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown(Error)
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknown(let error):
            return error.localizedDescription
        case .custom(let message):
            return message
        }
    }
} 