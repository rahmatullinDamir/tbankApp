import Foundation
import Combine

protocol ExpenseAddViewModelDelegate: AnyObject {
    func expenseAddViewModelDidFinish()
}

protocol ExpenseAddViewModelling: ViewModel where State == ExpenseAddViewState, Intent == ExpenseAddViewIntent {
    var isAddButtonEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var selectedCategoryPublisher: AnyPublisher<String, Never> { get }
    var selectedParticipantsPublisher: AnyPublisher<[String], Never> { get }
    var availableCategories: [String] { get }
    var availableParticipants: [String] { get }
    var selectedParticipants: [String] { get }
    var delegate: ExpenseAddViewModelDelegate? { get set }
}

final class ExpenseAddViewModel: ExpenseAddViewModelling {
    @Published private(set) var state: ExpenseAddViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    @Published private(set) var isAddButtonEnabled: Bool = false
    @Published private(set) var error: String?
    @Published private(set) var selectedCategory: String = ""
    @Published private(set) var selectedParticipants: [String] = []
    
    var isAddButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        $isAddButtonEnabled.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    var selectedCategoryPublisher: AnyPublisher<String, Never> {
        $selectedCategory.eraseToAnyPublisher()
    }
    
    var selectedParticipantsPublisher: AnyPublisher<[String], Never> {
        $selectedParticipants.eraseToAnyPublisher()
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    weak var delegate: ExpenseAddViewModelDelegate?
    
    private let tripId: Int64
    private let expenseService: ExpenseServicing
    private let categoryService: CategoryServicing
    private let tripService: TripServicing
    
    private var description: String = ""
    private var amount: String = ""
    private var categories: [CategoryDto] = []
    private var participants: [UserDto] = []
    private var currentUser: UserDto?
    private var categoryBudgets: [Int64: Double] = [:]
    private var categorySpent: [Int64: Double] = [:]
    
    var availableCategories: [String] {
        categories.map { $0.name }
    }
    
    var availableParticipants: [String] {
        participants.map { "\($0.firstName) \($0.lastName)" }
    }
    
    init(
        tripId: Int64,
        expenseService: ExpenseServicing = ExpenseService(),
        categoryService: CategoryServicing = CategoryService(),
        tripService: TripServicing = TripService()
    ) {
        self.tripId = tripId
        self.expenseService = expenseService
        self.categoryService = categoryService
        self.tripService = tripService
    }
    
    func trigger(_ intent: ExpenseAddViewIntent) {
        switch intent {
        case .onDidLoad:
            Task { await loadInitialData() }
        case .updateDescription(let text):
            description = text
            updateAddButtonState()
        case .updateAmount(let text):
            amount = text
            validateAndUpdateAmount(text)
        case .selectCategory(let category):
            selectedCategory = category
            validateAndUpdateAmount(amount)
        case .selectParticipant(let participant):
            toggleParticipant(participant)
            updateAddButtonState()
        case .addExpense:
            Task { await addExpense() }
        }
    }
    
    private func toggleParticipant(_ participant: String) {
        if selectedParticipants.contains(participant) {
            selectedParticipants.removeAll { $0 == participant }
        } else {
            selectedParticipants.append(participant)
        }
    }
    
    private func validateAndUpdateAmount(_ text: String) {
        guard let amountValue = Double(text),
              let category = categories.first(where: { $0.name == selectedCategory }),
              let categoryId = category.id else {
            amount = text
            updateAddButtonState()
            return
        }
        
        let plannedBudget = categoryBudgets[categoryId] ?? 0
        let spentAmount = categorySpent[categoryId] ?? 0
        let remainingBudget = plannedBudget - spentAmount
        
        if amountValue > remainingBudget {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            formatter.maximumFractionDigits = 0
            let formattedBudget = formatter.string(from: NSNumber(value: remainingBudget)) ?? "0"
            
            self.error = "Сумма превышает оставшийся бюджет категории (\(formattedBudget) ₽)"
            isAddButtonEnabled = false
        } else {
            self.error = nil
            amount = text
            updateAddButtonState()
        }
    }
    
    private func updateAddButtonState() {
        isAddButtonEnabled = !description.isEmpty &&
        !amount.isEmpty &&
        !selectedCategory.isEmpty &&
        !selectedParticipants.isEmpty &&
        Double(amount) != nil &&
        error == nil
    }
    
    private func addExpense() async {
        guard let amountValue = Double(amount),
              let category = categories.first(where: { $0.name == selectedCategory }),
              let categoryId = category.id,
              let currentUser = currentUser else {
            self.error = "Некорректные данные"
            return
        }
        
        let plannedBudget = categoryBudgets[categoryId] ?? 0
        let spentAmount = categorySpent[categoryId] ?? 0
        let remainingBudget = plannedBudget - spentAmount
        
        guard amountValue <= remainingBudget else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            formatter.maximumFractionDigits = 0
            let formattedBudget = formatter.string(from: NSNumber(value: remainingBudget)) ?? "0"
            
            self.error = "Сумма превышает оставшийся бюджет категории (\(formattedBudget) ₽)"
            return
        }
        
        let selectedUserPhoneNumbers = participants
            .filter { participant in
                selectedParticipants.contains("\(participant.firstName) \(participant.lastName)")
            }
            .map { $0.phoneNumber }
        
        do {
            state = .loading
            
            let expenseDto = ExpenseDto(
                id: nil,
                categoryId: categoryId,
                amount: amountValue,
                description: description,
                status: .ACTUAL,
                payerId: currentUser.id,
                phoneNumbersOfDebtors: selectedUserPhoneNumbers,
                date: Date()
            )
            
            try await expenseService.createExpense(tripId: tripId, expense: expenseDto)
            
            state = .content
            DispatchQueue.main.async {
                self.delegate?.expenseAddViewModelDidFinish()
            }
        } catch {
            self.error = error.localizedDescription
            state = .error(error.localizedDescription)
        }
    }
    
    private func loadInitialData() async {
        do {
            state = .loading
            
            let expenses = try await expenseService.getAllExpenses(tripId: tripId, status: nil, category: nil)
            
            let allCategories = try await categoryService.getAllCategories()
            
            var plannedBudgets: [Int64: Double] = [:]
            var spentAmounts: [Int64: Double] = [:]
            
            for expense in expenses.plannedExpenses {
                plannedBudgets[expense.categoryId, default: 0] += expense.amount
            }
            
            for expense in expenses.actualExpenses {
                spentAmounts[expense.categoryId, default: 0] += expense.amount
            }
            
            self.categoryBudgets = plannedBudgets
            self.categorySpent = spentAmounts
            
            let usedCategoryIds = Set(expenses.plannedExpenses.map { $0.categoryId } + expenses.actualExpenses.map { $0.categoryId })
            categories = allCategories.filter { category in
                guard let categoryId = category.id else { return false }
                return usedCategoryIds.contains(categoryId)
            }
            
            let participants = try await tripService.getParticipants(tripId: tripId)
            self.participants = participants
            
            if let currentUserPhoneNumber = KeychainManager.shared.getPhoneNumber(),
               let user = participants.first(where: { $0.phoneNumber == currentUserPhoneNumber }) {
                self.currentUser = user
            }
            
            state = .content
        } catch {
            self.error = error.localizedDescription
            state = .error(error.localizedDescription)
        }
    }
} 
 
