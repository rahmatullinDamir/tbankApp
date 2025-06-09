import Foundation

enum ExpenseStatus: String, Codable {
    case PLANNED
    case ACTUAL
    case PENDING
    case APPROVED
    case REJECTED
}

struct ExpenseDto: Codable {
    let id: Int64?
    let categoryId: Int64
    let amount: Double
    let description: String?
    let status: ExpenseStatus
    let payerId: Int64?
    let phoneNumbersOfDebtors: [String]?
    let date: Date
    
    init(id: Int64? = nil,
         categoryId: Int64,
         amount: Double,
         description: String? = nil,
         status: ExpenseStatus,
         payerId: Int64? = nil,
         phoneNumbersOfDebtors: [String]? = nil,
         date: Date) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.description = description
        self.status = status
        self.payerId = payerId
        self.phoneNumbersOfDebtors = phoneNumbersOfDebtors
        self.date = date
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case categoryId
        case amount
        case description
        case status
        case payerId
        case phoneNumbersOfDebtors
        case date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(status.rawValue, forKey: .status)
        try container.encodeIfPresent(payerId, forKey: .payerId)
        try container.encode(phoneNumbersOfDebtors ?? [], forKey: .phoneNumbersOfDebtors)
        try container.encode(date.apiFormatted, forKey: .date)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        categoryId = try container.decode(Int64.self, forKey: .categoryId)
        amount = try container.decode(Double.self, forKey: .amount)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        status = try container.decode(ExpenseStatus.self, forKey: .status)
        payerId = try container.decodeIfPresent(Int64.self, forKey: .payerId)
        phoneNumbersOfDebtors = try container.decodeIfPresent([String].self, forKey: .phoneNumbersOfDebtors)
        
        let dateString = try container.decode(String.self, forKey: .date)
        if let parsedDate = Date.fromAPIString(dateString) {
            date = parsedDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Invalid date format")
        }
    }
}

struct ExpenseListDto: Codable {
    let plannedExpenses: [ExpenseDto]
    let actualExpenses: [ExpenseDto]
    let payers: [UserDto?]
    
    init(plannedExpenses: [ExpenseDto], actualExpenses: [ExpenseDto], payers: [UserDto?]) {
        self.plannedExpenses = plannedExpenses
        self.actualExpenses = actualExpenses
        self.payers = payers
    }
    
    private enum CodingKeys: String, CodingKey {
        case plannedExpenses
        case actualExpenses
        case payers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plannedExpenses = try container.decode([ExpenseDto].self, forKey: .plannedExpenses)
        actualExpenses = try container.decode([ExpenseDto].self, forKey: .actualExpenses)
        
        var payersArray: [UserDto?] = []
        var payersContainer = try container.nestedUnkeyedContainer(forKey: .payers)
        while !payersContainer.isAtEnd {
            if try payersContainer.decodeNil() {
                payersArray.append(nil)
            } else {
                let payer = try payersContainer.decode(UserDto.self)
                payersArray.append(payer)
            }
        }
        payers = payersArray
    }
} 
