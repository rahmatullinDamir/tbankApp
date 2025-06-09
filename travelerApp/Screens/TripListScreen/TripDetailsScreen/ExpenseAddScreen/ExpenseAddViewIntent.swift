enum ExpenseAddViewIntent {
    case onDidLoad
    case updateDescription(String)
    case updateAmount(String)
    case selectCategory(String)
    case selectParticipant(String)
    case addExpense
} 