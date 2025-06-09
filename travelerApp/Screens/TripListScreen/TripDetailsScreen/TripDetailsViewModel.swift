import Foundation
import Combine

protocol TripDetailsViewModelDelegate: AnyObject {
    func tripDetailsViewModelDidFinish()
    func tripDetailsViewModelDidRequestAddExpense(_ tripId: Int64)
}

protocol TripDetailsViewModelling: ViewModel where State == TripDetailsViewState, Intent == TripDetailsViewIntent {
    var tripDetailsPublisher: AnyPublisher<TripDetailsViewData, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var delegate: TripDetailsViewModelDelegate? { get set }
    func getPayerName(for payerId: Int64?) -> String?
}

struct TripCategoryDetails {
    let name: String
    let icon: String
    let color: String
    let percentage: Double
    let amount: Double
    let plannedAmount: Double
}

struct TripDetailsViewData {
    let name: String
    let dateRange: String
    let participantsCount: Int
    let totalBudget: Double
    let spentAmount: Double
    let categories: [TripCategoryDetails]
    let expenses: [ExpenseDto]
    let participants: [UserDto]
}

final class TripDetailsViewModel: TripDetailsViewModelling {
    @Published private(set) var state: TripDetailsViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    @Published private(set) var tripDetails: TripDetailsViewData?
    @Published private(set) var error: String?
    
    var tripDetailsPublisher: AnyPublisher<TripDetailsViewData, Never> {
        $tripDetails.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    weak var delegate: TripDetailsViewModelDelegate?
    
    private let trip: TripDto
    private let tripService: TripServicing
    private let expenseService: ExpenseServicing
    private let categoryService: CategoryServicing
    
    init(
        trip: TripDto,
        tripService: TripServicing = TripService(),
        expenseService: ExpenseServicing = ExpenseService(),
        categoryService: CategoryServicing = CategoryService()
    ) {
        self.trip = trip
        self.tripService = tripService
        self.expenseService = expenseService
        self.categoryService = categoryService
    }
    
    func trigger(_ intent: TripDetailsViewIntent) {
        switch intent {
        case .onDidLoad:
            Task { await loadTripDetails() }
        case .addExpense:
            delegate?.tripDetailsViewModelDidRequestAddExpense(trip.id)
        }
    }
    
    private func loadTripDetails() async {
        do {
            state = .loading
            
            let freshTripData = try await tripService.getTripWithDetails(id: trip.id)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            let startDateStr = dateFormatter.string(from: freshTripData.startDate)
            let endDateStr = freshTripData.endDate.map { dateFormatter.string(from: $0) } ?? startDateStr
            
            let expenses = try await expenseService.getAllExpenses(tripId: freshTripData.id, status: nil, category: nil)
            let spentAmount = expenses.actualExpenses
                .filter { $0.payerId != nil }
                .reduce(0) { $0 + $1.amount }
            
            let categories = try await loadCategories()
            
            let participants = try await tripService.getParticipants(tripId: trip.id)
            
            let tripDetails = TripDetailsViewData(
                name: freshTripData.name,
                dateRange: "\(startDateStr) - \(endDateStr)",
                participantsCount: freshTripData.participantsCount ?? 0,
                totalBudget: freshTripData.totalBudget,
                spentAmount: spentAmount,
                categories: categories,
                expenses: expenses.actualExpenses,
                participants: participants
            )
            
            self.tripDetails = tripDetails
            state = .content(tripDetails)
            
        } catch {
            self.error = error.localizedDescription
            state = .error(error.localizedDescription)
        }
    }
    
    private func loadCategories() async throws -> [TripCategoryDetails] {
        let expenses = try await expenseService.getAllExpenses(tripId: trip.id, status: nil, category: nil)
        
        let actualExpensesWithPayer = expenses.actualExpenses.filter { $0.payerId != nil }
        
        var categories = try await categoryService.getAllCategories()
        
        let usedCategoryIds = Set(expenses.plannedExpenses.map { $0.categoryId } + expenses.actualExpenses.map { $0.categoryId })
        
        var plannedAmountsByCategory: [Int64: Double] = [:]
        for expense in expenses.plannedExpenses {
            plannedAmountsByCategory[expense.categoryId, default: 0] += expense.amount
        }
        
        var actualAmountsByCategory: [Int64: Double] = [:]
        for expense in actualExpensesWithPayer {
            actualAmountsByCategory[expense.categoryId, default: 0] += expense.amount
        }
        
        var categoryDetails: [TripCategoryDetails] = []
        for category in categories {
            guard let categoryId = category.id,
                  usedCategoryIds.contains(categoryId) else { continue }
            
            let plannedAmount = plannedAmountsByCategory[categoryId] ?? 0
            let actualAmount = actualAmountsByCategory[categoryId] ?? 0
            
            let completionPercentage = plannedAmount > 0 ? (actualAmount / plannedAmount) * 100 : 0
            
            let budgetPercentage = (plannedAmount / trip.totalBudget) * 100
            
            let displayPercentage = (completionPercentage / 100) * budgetPercentage
            
            let details = TripCategoryDetails(
                name: category.name,
                icon: getCategoryIcon(for: category.name),
                color: category.color,
                percentage: completionPercentage,
                amount: actualAmount,
                plannedAmount: plannedAmount
            )
            categoryDetails.append(details)
        }
        
        return categoryDetails.sorted { $0.percentage > $1.percentage }
    }
    
    private func getCategoryIcon(for categoryName: String) -> String {
        return CategoryIcon.from(categoryName: categoryName).rawValue
    }
    
    private func getCategoryColor(for categoryName: String) -> String {
        return CategoryColors.color(from: categoryName)
    }
    
    private func getCategoryIcon(for category: TripCategoryType) -> String {
        return CategoryIcon.from(category: category).rawValue
    }
    
    func getPayerName(for payerId: Int64?) -> String? {
        guard let payerId = payerId,
              let tripDetails = tripDetails else { return nil }
        
        return tripDetails.participants
            .first { $0.id == payerId }
            .map { "\($0.firstName) \($0.lastName)" }
    }
}
 
