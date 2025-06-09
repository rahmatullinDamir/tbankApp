import Foundation
@testable import travelerApp

final class MockExpenseService: ExpenseServicing {
    var mockExpenses: ExpenseListDto?
    var mockError: Error?
    
    func getAllExpenses(tripId: Int64, status: ExpenseStatus?, category: String?) async throws -> ExpenseListDto {
        if let error = mockError {
            throw error
        }
        
        return mockExpenses ?? ExpenseListDto(
            plannedExpenses: [],
            actualExpenses: [],
            payers: []
        )
    }
    
    func getExpense(tripId: Int64, expenseId: Int64) async throws -> ExpenseDto {
        throw NetworkError.custom("Not implemented")
    }
    
    func createExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto {
        throw NetworkError.custom("Not implemented")
    }
    
    func updateExpense(tripId: Int64, expense: ExpenseDto) async throws -> ExpenseDto {
        throw NetworkError.custom("Not implemented")
    }
    
    func deleteExpense(tripId: Int64, expenseId: Int64) async throws {
        throw NetworkError.custom("Not implemented")
    }
} 