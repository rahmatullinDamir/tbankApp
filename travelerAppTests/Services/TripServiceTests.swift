import XCTest
@testable import travelerApp

final class TripServiceTests: XCTestCase {
    var sut: TripService!
    var mockNetworkService: MockNetworkService!
    var mockExpenseService: MockExpenseService!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockExpenseService = MockExpenseService()
        mockCoreDataManager = MockCoreDataManager()
        sut = TripService(
            networkService: mockNetworkService,
            expenseService: mockExpenseService,
            coreDataManager: mockCoreDataManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockExpenseService = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    func testGetAllTrips_WhenNetworkSucceeds_ShouldReturnTripsAndSaveToCache() async throws {
        // Given
        let expectedTrips = [createMockTrip(), createMockTrip()]
        mockNetworkService.mockResponse = expectedTrips
        
        // When
        let trips = try await sut.getAllTrips(status: nil)
        
        // Then
        XCTAssertEqual(trips.count, expectedTrips.count)
        XCTAssertEqual(mockCoreDataManager.savedTrips.count, expectedTrips.count)
    }
    
    func testGetAllTrips_WhenNetworkFails_ShouldReturnCachedTrips() async throws {
        // Given
        let cachedTrips = [createMockTrip(), createMockTrip()]
        mockNetworkService.mockError = NetworkError.noInternet
        mockCoreDataManager.mockTrips = cachedTrips
        
        // When
        let trips = try await sut.getAllTrips(status: nil)
        
        // Then
        XCTAssertEqual(trips.count, cachedTrips.count)
    }
    
    func testGetTripWithDetails_ShouldIncludeParticipantsAndExpenses() async throws {
        // Given
        let mockTrip = createMockTrip()
        let mockParticipants = [createMockUser(), createMockUser()]
        let mockExpenses = ExpenseListDto(
            plannedExpenses: [createMockExpense()],
            actualExpenses: [createMockExpense()],
            payers: [createMockUser()]
        )
        
        mockNetworkService.mockResponse = mockTrip
        mockNetworkService.mockParticipantsResponse = mockParticipants
        mockExpenseService.mockExpenses = mockExpenses
        
        // When
        let tripWithDetails = try await sut.getTripWithDetails(id: 1)
        
        // Then
        XCTAssertEqual(tripWithDetails.id, mockTrip.id)
        XCTAssertEqual(tripWithDetails.participantsCount, mockParticipants.count)
        XCTAssertNotNil(tripWithDetails.spentAmount)
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
    
    private func createMockExpense() -> ExpenseDto {
        ExpenseDto(
            id: Int64.random(in: 1...1000),
            categoryId: 1,
            amount: 100.0,
            description: "Test expense",
            status: .PLANNED,
            payerId: nil,
            phoneNumbersOfDebtors: [],
            date: Date()
        )
    }
} 