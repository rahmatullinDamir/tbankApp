import XCTest
import Combine
@testable import travelerApp

final class TripListViewModelTests: XCTestCase {
    var sut: TripListViewModel!
    var mockTripService: MockTripService!
    var mockAuthService: MockAuthService!
    var mockDelegate: MockTripListViewModelDelegate!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockTripService = MockTripService()
        mockAuthService = MockAuthService()
        mockDelegate = MockTripListViewModelDelegate()
        cancellables = Set<AnyCancellable>()
        
        let authResponse = AuthResponse(
            userDto: createMockUser(),
            jwtTokenPairDto: JwtTokenPairDto(accessToken: "test_token", refreshToken: "test_refresh_token")
        )
        
        sut = TripListViewModel(
            authResponse: authResponse,
            tripService: mockTripService,
            authService: mockAuthService
        )
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockTripService = nil
        mockAuthService = nil
        mockDelegate = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState_ShouldBeLoading() {
        // Then
        if case .loading = sut.state {
            XCTAssert(true)
        } else {
            XCTFail("Initial state should be loading")
        }
    }
    
    func testLoadTrips_WhenSuccessful_ShouldUpdateStateToContent() async {
        // Given
        let expectedTrips = [createMockTrip(), createMockTrip()]
        mockTripService.mockTrips = expectedTrips
        
        // When
        sut.trigger(.onDidLoad)
        
        // Then
        let expectation = XCTestExpectation(description: "State should update to content")
        sut.stateDidChange
            .sink {
                if case .content(let trips) = self.sut.state {
                    XCTAssertEqual(trips.count, expectedTrips.count)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testLoadTrips_WhenFails_ShouldUpdateStateToError() async {
        // Given
        mockTripService.mockError = NetworkError.noInternet
        
        // When
        sut.trigger(.onDidLoad)
        
        // Then
        let expectation = XCTestExpectation(description: "State should update to error")
        sut.stateDidChange
            .sink {
                if case .error = self.sut.state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testTripSelection_ShouldNotifyDelegate() {
        // Given
        let mockTrip = createMockTrip()
        mockTripService.mockTrips = [mockTrip]
        
        // When
        sut.trigger(.onDidLoad)
        sut.trigger(.tripSelected(IndexPath(item: 0, section: 0)))
        
        // Then
        XCTAssertEqual(mockDelegate.selectedTrip?.id, mockTrip.id)
    }
    
    // MARK: - Helper Methods
    
    private func createMockTrip() -> TripDto {
        let creator = createMockUser()
        let now = Date()
        
        let jsonString = """
        {
            "id": \(Int64.random(in: 1...1000)),
            "name": "Test Trip",
            "creator": {
                "id": \(creator.id),
                "firstName": "\(creator.firstName)",
                "lastName": "\(creator.lastName)",
                "phoneNumber": "\(creator.phoneNumber)"
            },
            "createdDate": "\(now.apiFormatted)",
            "startDate": "\(now.apiFormatted)",
            "endDate": null,
            "totalBudget": 1000.0,
            "status": "PLANNED"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8),
              let tripDto = try? JSONDecoder().decode(TripDto.self, from: jsonData) else {
            fatalError("Failed to create mock TripDto")
        }
        
        return tripDto
    }
    
    private func createMockUser() -> UserDto {
        UserDto(
            id: Int64.random(in: 1...1000),
            firstName: "John",
            lastName: "Doe",
            phoneNumber: "+1234567890"
        )
    }
}

// MARK: - Mock Classes

final class MockTripListViewModelDelegate: TripListViewModelDelegate {
    var selectedTrip: TripDto?
    
    func tripListViewModelDidSelectTrip(_ trip: TripDto) {
        selectedTrip = trip
    }
    
    func tripListViewModelDidRequestNewTrip() {}
    func tripListViewModelDidRequestOpenNotifications() {}
    func showCreateTrip() {}
    func showTripDetails(_ trip: TripDto) {
        selectedTrip = trip
    }
}

final class MockTripService: TripServicing {
    var mockTrips: [TripDto] = []
    var mockError: Error?
    
    func getAllTrips(status: TripStatus?) async throws -> [TripDto] {
        if let error = mockError {
            throw error
        }
        return mockTrips
    }
    
    func getAllTripsWithDetails(status: TripStatus?) async throws -> [TripDto] {
        if let error = mockError {
            throw error
        }
        return mockTrips
    }
    
    func getTrip(id: Int64) async throws -> TripDto {
        if let error = mockError {
            throw error
        }
        return mockTrips.first ?? createMockTrip()
    }
    
    func getTripWithDetails(id: Int64) async throws -> TripDto {
        if let error = mockError {
            throw error
        }
        return mockTrips.first ?? createMockTrip()
    }
    
    func createTrip(_ trip: TripCreateDto) async throws -> TripDto {
        throw NetworkError.custom("Not implemented")
    }
    
    func updateTripStatus(id: Int64, status: TripStatus) async throws -> TripDto {
        throw NetworkError.custom("Not implemented")
    }
    
    func deleteTrip(id: Int64) async throws {
        throw NetworkError.custom("Not implemented")
    }
    
    func getParticipants(tripId: Int64) async throws -> [UserDto] {
        throw NetworkError.custom("Not implemented")
    }
    
    func addParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws {
        throw NetworkError.custom("Not implemented")
    }
    
    func deleteParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws {
        throw NetworkError.custom("Not implemented")
    }
    
    func addTripCategory(tripId: Int64, categoryId: Int64, budget: Double) async throws {
        throw NetworkError.custom("Not implemented")
    }
    
    private func createMockTrip() -> TripDto {
        let creator = UserDto(id: 1, firstName: "John", lastName: "Doe", phoneNumber: "+1234567890")
        let now = Date()
        
        let jsonString = """
        {
            "id": \(Int64.random(in: 1...1000)),
            "name": "Test Trip",
            "creator": {
                "id": \(creator.id),
                "firstName": "\(creator.firstName)",
                "lastName": "\(creator.lastName)",
                "phoneNumber": "\(creator.phoneNumber)"
            },
            "createdDate": "\(now.apiFormatted)",
            "startDate": "\(now.apiFormatted)",
            "endDate": null,
            "totalBudget": 1000.0,
            "status": "PLANNED"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8),
              let tripDto = try? JSONDecoder().decode(TripDto.self, from: jsonData) else {
            fatalError("Failed to create mock TripDto")
        }
        
        return tripDto
    }
}

final class MockAuthService: AuthServicing {
    func login(credentials: LoginCredentials) async throws -> AuthResponse {
        throw NetworkError.custom("Not implemented")
    }
    
    func register(credentials: RegisterCredentials) async throws -> AuthResponse {
        throw NetworkError.custom("Not implemented")
    }
    
    func refreshToken(_ token: String) async throws -> JwtTokenPairDto {
        throw NetworkError.custom("Not implemented")
    }
} 