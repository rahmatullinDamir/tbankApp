import Foundation

enum TripStatus: String, Codable {
    case PLANNED
    case ACTIVE
    case COMPLETED
}

struct TripCreateDto: Codable {
    let name: String
    let createdDate: Date?
    let startDate: Date
    let endDate: Date?
    let creatorPhoneNumber: String?
    let participants: [String]?
    let totalBudget: Double?
    
    init(
        name: String,
        createdDate: Date? = nil,
        startDate: Date,
        endDate: Date? = nil,
        creatorPhoneNumber: String? = nil,
        participants: [String]? = nil,
        totalBudget: Double? = nil
    ) {
        self.name = name
        self.createdDate = createdDate
        self.startDate = startDate
        self.endDate = endDate
        self.creatorPhoneNumber = creatorPhoneNumber
        self.participants = participants
        self.totalBudget = totalBudget
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, createdDate, startDate, endDate, creatorPhoneNumber, participants, totalBudget
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if let createdDate = createdDate {
            try container.encode(createdDate.apiFormatted, forKey: .createdDate)
        }
        try container.encode(startDate.apiFormatted, forKey: .startDate)
        if let endDate = endDate {
            try container.encode(endDate.apiFormatted, forKey: .endDate)
        }
        if let creatorPhoneNumber = creatorPhoneNumber {
            try container.encode(creatorPhoneNumber, forKey: .creatorPhoneNumber)
        }
        if let participants = participants {
            try container.encode(participants, forKey: .participants)
        }
        if let totalBudget = totalBudget {
            try container.encode(totalBudget, forKey: .totalBudget)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdDate) {
            createdDate = Date.fromAPIString(dateString)
        } else {
            createdDate = nil
        }
        let startDateString = try container.decode(String.self, forKey: .startDate)
        guard let date = Date.fromAPIString(startDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .startDate, in: container, debugDescription: "Invalid date format")
        }
        startDate = date
        
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = Date.fromAPIString(endDateString)
        } else {
            endDate = nil
        }
        
        creatorPhoneNumber = try container.decodeIfPresent(String.self, forKey: .creatorPhoneNumber)
        participants = try container.decodeIfPresent([String].self, forKey: .participants)
        totalBudget = try container.decodeIfPresent(Double.self, forKey: .totalBudget)
    }
}

struct TripDto: Codable {
    let id: Int64
    let name: String
    let creator: UserDto
    let createdDate: Date
    let startDate: Date
    let endDate: Date?
    var totalBudget: Double
    let status: TripStatus
    
    var participantsCount: Int?
    var spentAmount: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, creator, createdDate, startDate, endDate, totalBudget, status
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(creator, forKey: .creator)
        try container.encode(createdDate.apiFormatted, forKey: .createdDate)
        try container.encode(startDate.apiFormatted, forKey: .startDate)
        if let endDate = endDate {
            try container.encode(endDate.apiFormatted, forKey: .endDate)
        }
        try container.encode(totalBudget, forKey: .totalBudget)
        try container.encode(status, forKey: .status)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        creator = try container.decode(UserDto.self, forKey: .creator)
        
        let createdDateString = try container.decode(String.self, forKey: .createdDate)
        guard let createdDate = Date.fromAPIString(createdDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Invalid date format")
        }
        self.createdDate = createdDate
        
        let startDateString = try container.decode(String.self, forKey: .startDate)
        guard let startDate = Date.fromAPIString(startDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .startDate, in: container, debugDescription: "Invalid date format")
        }
        self.startDate = startDate
        
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = Date.fromAPIString(endDateString)
        } else {
            endDate = nil
        }
        
        totalBudget = try container.decode(Double.self, forKey: .totalBudget)
        status = try container.decode(TripStatus.self, forKey: .status)
        participantsCount = nil
        spentAmount = nil
    }
    
    var progressPercentage: Float {
        guard let spent = spentAmount, totalBudget > 0 else { return 0 }
        return Float(spent / totalBudget)
    }
    
    var formattedParticipantsCount: String {
        return "👤 \(participantsCount ?? 0)"
    }
}

typealias TripListDto = [TripDto]

struct ParticipantAddDeleteDto: Codable {
    let phoneNumber: String
}

struct TripBudgetCategory: Equatable {
    let type: TripCategoryType
    var amount: Double
    var percentage: Double
    
    var isSelected: Bool
    
    init(type: TripCategoryType, amount: Double = 0, percentage: Double = 0, isSelected: Bool = false) {
        self.type = type
        self.amount = amount
        self.percentage = percentage
        self.isSelected = isSelected
    }
}

enum TripCategoryType: CaseIterable {
    case tickets
    case hotels
    case food
    case entertainment
    case insurance
    case other
    
    var title: String {
        switch self {
        case .tickets:
            return CategoryTitle.tickets
        case .hotels:
            return CategoryTitle.hotels
        case .food:
            return CategoryTitle.food
        case .entertainment:
            return CategoryTitle.entertainment
        case .insurance:
            return CategoryTitle.insurance
        case .other:
            return CategoryTitle.other
        }
    }
    
    var color: String {
        return CategoryColors.color(from: title)
    }
}

public struct CreateTripData {
    public var name: String = ""
    public var startDate: Date?
    public var endDate: Date?
    public var totalBudget: Int?
    public var categories: [String] = []
    public var isFormValid: Bool = false
    
    public init() {}
}
