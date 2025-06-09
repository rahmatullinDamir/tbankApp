import Foundation

enum CreateTripViewIntent {
    case onDidLoad
    case updateName(String)
    case updateStartDate(Date)
    case updateEndDate(Date)
    case updateBudget(Int)
    case updateCategories([String])
    case nextStep
    case cancel
} 
