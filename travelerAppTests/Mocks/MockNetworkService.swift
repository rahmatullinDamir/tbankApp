import Foundation
@testable import travelerApp

final class MockNetworkService: NetworkServicing {
    var mockResponse: Any?
    var mockError: Error?
    var mockParticipantsResponse: [UserDto]?
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        if endpoint.url.absoluteString.contains("/participants") && mockParticipantsResponse != nil {
            return mockParticipantsResponse as! T
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }
        
        return response
    }
    
    func request(_ endpoint: APIEndpoint) async throws {
        if let error = mockError {
            throw error
        }
    }
} 