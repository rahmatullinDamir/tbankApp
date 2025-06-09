import Foundation

protocol TripServicing {
    func getAllTrips(status: TripStatus?) async throws -> [TripDto]
    func getTrip(id: Int64) async throws -> TripDto
    func createTrip(_ trip: TripCreateDto) async throws -> TripDto
    func updateTripStatus(id: Int64, status: TripStatus) async throws -> TripDto
    func deleteTrip(id: Int64) async throws
    func getParticipants(tripId: Int64) async throws -> [UserDto]
    func addParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws
    func deleteParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws
    func getTripWithDetails(id: Int64) async throws -> TripDto
    func getAllTripsWithDetails(status: TripStatus?) async throws -> [TripDto]
    func addTripCategory(tripId: Int64, categoryId: Int64, budget: Double) async throws
}

final class TripService: TripServicing {
    private let networkService: NetworkServicing
    private let expenseService: ExpenseServicing
    private let coreDataManager: CoreDataManaging
    
    init(
        networkService: NetworkServicing = NetworkService.shared,
        expenseService: ExpenseServicing = ExpenseService(),
        coreDataManager: CoreDataManaging = CoreDataManager.shared
    ) {
        self.networkService = networkService
        self.expenseService = expenseService
        self.coreDataManager = coreDataManager
    }
    
    func getAllTrips(status: TripStatus?) async throws -> [TripDto] {
        do {
            let endpoint = TripEndpoints.getAllTrips(status: status)
            let trips: TripListDto = try await networkService.request(endpoint)
            trips.forEach { saveOfflineData($0) }
            return trips
        } catch {
            let offlineTrips = coreDataManager.fetchTrips(with: status)
            if !offlineTrips.isEmpty {
                return offlineTrips
            }
            throw error
        }
    }
    
    func getTrip(id: Int64) async throws -> TripDto {
        do {
            let endpoint = TripEndpoints.getTrip(id: id)
            let trip: TripDto = try await networkService.request(endpoint)
            saveOfflineData(trip)
            return trip
        } catch {
            let offlineTrips = coreDataManager.fetchTrips(with: nil)
            if let trip = offlineTrips.first(where: { $0.id == id }) {
                return trip
            }
            throw error
        }
    }
    
    func createTrip(_ trip: TripCreateDto) async throws -> TripDto {
        let endpoint = TripEndpoints.createTrip(trip: trip)
        let createdTrip: TripDto = try await networkService.request(endpoint)
        saveOfflineData(createdTrip)
        return createdTrip
    }
    
    func updateTripStatus(id: Int64, status: TripStatus) async throws -> TripDto {
        let endpoint = TripEndpoints.updateTripStatus(id: id, status: status)
        let updatedTrip: TripDto = try await networkService.request(endpoint)
        saveOfflineData(updatedTrip)
        return updatedTrip
    }
    
    func deleteTrip(id: Int64) async throws {
        let endpoint = TripEndpoints.deleteTrip(id: id)
        try await networkService.request(endpoint)
    }
    
    func getParticipants(tripId: Int64) async throws -> [UserDto] {
        let endpoint = TripEndpoints.getParticipants(tripId: tripId)
        return try await networkService.request(endpoint)
    }
    
    func addParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws {
        let endpoint = TripEndpoints.addParticipant(tripId: tripId, participant: participant)
        try await networkService.request(endpoint)
    }
    
    func deleteParticipant(tripId: Int64, participant: ParticipantAddDeleteDto) async throws {
        let endpoint = TripEndpoints.deleteParticipant(tripId: tripId, participant: participant)
        try await networkService.request(endpoint)
    }
    
    func getTripWithDetails(id: Int64) async throws -> TripDto {
        var trip = try await getTrip(id: id)
        
        do {
            let participants = try await getParticipants(tripId: id)
            trip.participantsCount = participants.count
        } catch {
            trip.participantsCount = 0
        }
        
        do {
            let expenses = try await expenseService.getAllExpenses(tripId: id, status: nil, category: nil)
            let plannedTotal = expenses.plannedExpenses.reduce(0) { $0 + $1.amount }
            
            let actualTotal = expenses.actualExpenses
                .filter { $0.payerId != nil }
                .reduce(0) { $0 + $1.amount }
            
            trip.spentAmount = actualTotal
            if plannedTotal > 0 {
                trip.totalBudget = plannedTotal
            }
        } catch {
            trip.spentAmount = 0
        }
        
        return trip
    }
    
    func getAllTripsWithDetails(status: TripStatus?) async throws -> [TripDto] {
        let trips = try await getAllTrips(status: status)
        
        return try await withThrowingTaskGroup(of: TripDto.self) { group in
            for trip in trips {
                group.addTask {
                    do {
                        return try await self.getTripWithDetails(id: trip.id)
                    } catch {
                        return trip
                    }
                }
            }
            
            var updatedTrips: [TripDto] = []
            for try await trip in group {
                updatedTrips.append(trip)
            }
            
            return updatedTrips.sorted { $0.startDate > $1.startDate }
        }
    }
    
    func addTripCategory(tripId: Int64, categoryId: Int64, budget: Double) async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let categoryService = CategoryService()
        do {
            let categories = try await categoryService.getAllCategories()
            guard let existingCategory = categories.first(where: { $0.id == categoryId }) else {
                throw NetworkError.custom("Category not found")
            }
            
            let expense = ExpenseDto(
                categoryId: existingCategory.id ?? categoryId,
                amount: budget,
                description: nil,
                status: .PLANNED,
                payerId: nil,
                phoneNumbersOfDebtors: [],
                date: today
            )
            
            do {
                _ = try await expenseService.createExpense(tripId: tripId, expense: expense)
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
    
    func saveOfflineData<T>(_ data: T) {
        if let trip = data as? TripDto {
            coreDataManager.saveTrip(trip)
        }
    }
    
    func clearOfflineData() {
        coreDataManager.clearAllData()
    }
    
    func syncWithServer() async throws {
        let endpoint = TripEndpoints.getAllTrips(status: nil)
        let onlineTrips: TripListDto = try await networkService.request(endpoint)
        
        onlineTrips.forEach { trip in
            coreDataManager.saveTrip(trip)
        }
    }
} 
 
