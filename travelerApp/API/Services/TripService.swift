import Foundation

protocol TripServicing {
    func getAllTrips(status: TripStatus?) async throws -> [TripDto]
    func getTrip(id: Int64) async throws -> TripDto
    func createTrip(_ trip: TripCreateDto) async throws -> TripDto
    func updateTripStatus(id: Int64, status: TripStatus) async throws
    func deleteTrip(id: Int64) async throws
    func getParticipants(tripId: Int64) async throws -> [UserDto]
    func addParticipant(tripId: Int64, phoneNumber: String) async throws
    func deleteParticipant(tripId: Int64, phoneNumber: String) async throws
}

final class TripService: TripServicing {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAllTrips(status: TripStatus?) async throws -> [TripDto] {
        let endpoint = TripEndpoints.getAllTrips(status: status)
        return try await networkService.request(endpoint)
    }
    
    func getTrip(id: Int64) async throws -> TripDto {
        let endpoint = TripEndpoints.getTrip(id: id)
        return try await networkService.request(endpoint)
    }
    
    func createTrip(_ trip: TripCreateDto) async throws -> TripDto {
        let endpoint = TripEndpoints.createTrip(trip: trip)
        return try await networkService.request(endpoint)
    }
    
    func updateTripStatus(id: Int64, status: TripStatus) async throws {
        let endpoint = TripEndpoints.updateTripStatus(id: id, status: status)
        try await networkService.request(endpoint)
    }
    
    func deleteTrip(id: Int64) async throws {
        let endpoint = TripEndpoints.deleteTrip(id: id)
        try await networkService.request(endpoint)
    }
    
    func getParticipants(tripId: Int64) async throws -> [UserDto] {
        let endpoint = TripEndpoints.getParticipants(tripId: tripId)
        return try await networkService.request(endpoint)
    }
    
    func addParticipant(tripId: Int64, phoneNumber: String) async throws {
        let participant = ParticipantAddDeleteDto(phoneNumber: phoneNumber)
        let endpoint = TripEndpoints.addParticipant(tripId: tripId, participant: participant)
        try await networkService.request(endpoint)
    }
    
    func deleteParticipant(tripId: Int64, phoneNumber: String) async throws {
        let participant = ParticipantAddDeleteDto(phoneNumber: phoneNumber)
        let endpoint = TripEndpoints.deleteParticipant(tripId: tripId, participant: participant)
        try await networkService.request(endpoint)
    }
} 
