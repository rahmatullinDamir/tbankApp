import Foundation
import Alamofire

enum ExpenseEndpoints {
    case getAllExpenses(tripId: Int64, status: ExpenseStatus?, category: String?)
    case getExpense(tripId: Int64, expenseId: Int64)
    case createExpense(tripId: Int64, expense: ExpenseDto)
    case updateExpense(tripId: Int64, expense: ExpenseDto)
    case deleteExpense(tripId: Int64, expenseId: Int64)
}

extension ExpenseEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .getAllExpenses(let tripId, _, _), .createExpense(let tripId, _), .updateExpense(let tripId, _):
            return NetworkConstants.apiPath + "/trip/\(tripId)/expenses"
        case .getExpense(let tripId, let expenseId), .deleteExpense(let tripId, let expenseId):
            return NetworkConstants.apiPath + "/trip/\(tripId)/expenses/\(expenseId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllExpenses, .getExpense:
            return .get
        case .createExpense:
            return .post
        case .updateExpense:
            return .put
        case .deleteExpense:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAllExpenses(_, let status, let category):
            var params: [String: Any] = [:]
            if let status = status {
                params["status"] = status.rawValue
            }
            if let category = category {
                params["category"] = category
            }
            return params
            
        case .createExpense(_, let expense), .updateExpense(_, let expense):
            return try? expense.asDictionary()
            
        case .getExpense, .deleteExpense:
            return nil
        }
    }
} 
