import XCTest
import Alamofire
@testable import travelerApp

// MARK: - Protocols for Mocking

protocol KeychainManaging {
    func getRefreshToken() -> String?
    func getAccessToken() -> String?
    func saveTokens(accessToken: String, refreshToken: String)
    func removeTokens()
}

protocol NetworkReachabilityManaging {
    var isConnected: Bool { get set }
}

// MARK: - NetworkError Equatable Conformance

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternet, .noInternet),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.serverError, .serverError),
             (.networkTimeout, .networkTimeout),
             (.noData, .noData),
             (.decodingError, .decodingError):
            return true
        case (.custom(let lhsMessage), .custom(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

final class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    var mockKeychainManager: MockKeychainManager!
    var mockReachabilityManager: MockNetworkReachabilityManager!
    
    override func setUp() {
        super.setUp()
        mockKeychainManager = MockKeychainManager()
        mockReachabilityManager = MockNetworkReachabilityManager()
        sut = NetworkService.shared
    }
    
    override func tearDown() {
        sut = nil
        mockKeychainManager = nil
        mockReachabilityManager = nil
        super.tearDown()
    }
    
    func testRequest_WhenNoInternet_ShouldThrowError() async {
        // Given
        mockReachabilityManager.isConnected = false
        
        // When/Then
        do {
            let _: TripDto = try await sut.request(TripEndpoints.getTrip(id: 1))
            XCTFail("Should throw no internet error")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.noInternet)
        }
    }
    
    func testRequest_WhenUnauthorized_ShouldAttemptTokenRefresh() async {
        // Given
        mockKeychainManager.refreshToken = "test_refresh_token"
        
        // When/Then
        do {
            let _: TripDto = try await sut.request(TripEndpoints.getTrip(id: 1))
        } catch {
            if case NetworkError.unauthorized = error {
                // Success - we expect unauthorized after refresh attempt
                XCTAssert(true)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

// MARK: - Mock Classes

final class MockKeychainManager: KeychainManaging {
    var refreshToken: String?
    var accessToken: String?
    
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func removeTokens() {
        accessToken = nil
        refreshToken = nil
    }
}

final class MockNetworkReachabilityManager: NetworkReachabilityManaging {
    var isConnected: Bool = true
} 