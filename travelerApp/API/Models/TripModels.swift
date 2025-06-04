import Foundation

enum TripStatus: String, Codable {
    case PLANNED
    case ACTIVE
    case COMPLETED
}

struct TripCreateDto: Codable {
    let name: String
    let destination: String
    let createdDate: Date?
    let startDate: Date
    let creatorPhoneNumber: String?
    let participants: [String]?
}

struct TripDto: Codable {
    let id: Int64
    let name: String
    let destination: String
    let creator: UserDto
    let createdDate: Date
    let startDate: Date
    let endDate: Date?
    let totalBudget: Double
    let status: TripStatus
}

struct TripListDto: Codable {
    let trips: [TripDto]
}

struct ParticipantAddDeleteDto: Codable {
    let phoneNumber: String
}
