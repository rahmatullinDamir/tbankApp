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
}

struct ExpenseListDto: Codable {
    let plannedExpenses: [ExpenseDto]
    let actualExpenses: [ExpenseDto]
    let payers: [UserDto]
} 
