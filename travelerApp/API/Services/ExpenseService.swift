import Foundation

protocol ExpenseServicing {
    func getAllExpenses(tripId: Int64, status: ExpenseStatus?, category: String?) async throws -> ExpenseListDto
    func getExpense(tripId: Int64, expenseId: Int64) async throws -> ExpenseDto
    func createExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto
    func updateExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto
    func deleteExpense(tripId: Int64, expenseId: Int64) async throws
}

final class ExpenseService: ExpenseServicing {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func getAllExpenses(tripId: Int64, status: ExpenseStatus?, category: String?) async throws -> ExpenseListDto {
        let endpoint = ExpenseEndpoints.getAllExpenses(tripId: tripId, status: status, category: category)
        return try await networkService.request(endpoint)
    }
    
    func getExpense(tripId: Int64, expenseId: Int64) async throws -> ExpenseDto {
        let endpoint = ExpenseEndpoints.getExpense(tripId: tripId, expenseId: expenseId)
        return try await networkService.request(endpoint)
    }
    
    func createExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto {
        let endpoint = ExpenseEndpoints.createExpense(tripId: tripId, expense: expense)
        return try await networkService.request(endpoint)
    }
    
    func updateExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto {
        guard let id = expense.id else {
            throw NetworkError.invalidURL
        }
        let endpoint = ExpenseEndpoints.updateExpense(tripId: tripId, expense: expense)
        return try await networkService.request(endpoint)
    }
    
    func deleteExpense(tripId: Int64, expenseId: Int64) async throws {
        let endpoint = ExpenseEndpoints.deleteExpense(tripId: tripId, expenseId: expenseId)
        try await networkService.request(endpoint)
    }
} 
