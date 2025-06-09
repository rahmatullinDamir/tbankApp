import Foundation
@testable import travelerApp

final class MockCoreDataManager: CoreDataManaging {
    var mockTrips: [TripDto] = []
    var savedTrips: [TripDto] = []
    var mockError: Error?
    
    func fetchTrips(with status: TripStatus? = nil) -> [TripDto] {
        if let error = mockError {
            print("Mock error: \(error)")
            return []
        }
        return mockTrips
    }
    
    func saveTrip(_ trip: TripDto) {
        savedTrips.append(trip)
    }
    
    func clearAllData() {
        savedTrips.removeAll()
        mockTrips.removeAll()
    }
} 