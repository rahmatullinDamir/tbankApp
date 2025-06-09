import Foundation
import UIKit
import Combine

protocol BudgetDistributionViewModelDelegate: AnyObject {
    func budgetDistributionViewModelDidFinish(_ trip: TripDto)
}

protocol BudgetDistributionViewModelling: ViewModel where State == BudgetDistributionViewState, Intent == BudgetDistributionViewIntent {
    var totalBudget: Int { get }
    var categoryPercentages: [String: Double] { get }
    var isReadyToProceed: Bool { get }
    var error: String? { get }
    var selectedCategories: Set<String> { get }
    var totalPercentage: Double { get }
    var delegate: BudgetDistributionViewModelDelegate? { get set }
    
    var totalBudgetPublisher: AnyPublisher<Int, Never> { get }
    var isReadyToProceedPublisher: AnyPublisher<Bool, Never> { get }
    var categoryPercentagesPublisher: AnyPublisher<[String: Double], Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var defaultCategories: [(title: String, icon: String, color: UIColor)] { get }
    func getMaxAllowedPercentage(for category: String) -> Double
}

class BudgetDistributionViewModel: BudgetDistributionViewModelling {
    @Published private(set) var state: BudgetDistributionViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    var stateDidChange = ObservableObjectPublisher()
    
    @Published private(set) var totalBudget: Int = 0
    @Published private(set) var categoryPercentages: [String: Double] = [:]
    @Published private(set) var isReadyToProceed: Bool = false
    @Published private(set) var error: String?
    
    var totalBudgetPublisher: AnyPublisher<Int, Never> {
        $totalBudget.eraseToAnyPublisher()
    }
    
    var isReadyToProceedPublisher: AnyPublisher<Bool, Never> {
        $isReadyToProceed.eraseToAnyPublisher()
    }
    
    var categoryPercentagesPublisher: AnyPublisher<[String : Double], Never> {
        $categoryPercentages.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    private(set) var selectedCategories: Set<String> = []
    private let allCategories = ["Билеты", "Отели", "Питание", "Развлечения", "Страховка", "Остальное"]
    private var categoryIds: [String: Int64] = [:]
    
    var totalPercentage: Double {
        categoryPercentages.values.reduce(0, +)
    }
    
    let defaultCategories = [
        (title: "Билеты", icon: "airplane", color: UIColor(hex: CategoryColors.tickets.color)),
        (title: "Отели", icon: "house.fill", color: UIColor(hex: CategoryColors.hotels.color)),
        (title: "Питание", icon: "fork.knife", color: UIColor(hex: CategoryColors.food.color)),
        (title: "Развлечения", icon: "star.fill", color: UIColor(hex: CategoryColors.entertainment.color)),
        (title: "Страховка", icon: "cross.case.fill", color: UIColor(hex: CategoryColors.insurance.color)),
        (title: "Остальное", icon: "plus.circle.fill", color: UIColor(hex: CategoryColors.color(from: "default")))
    ]
    
    private let tripData: CreateTripData
    private let participants: [String]
    private let tripService: TripServicing
    private let categoryService: CategoryServicing
    private let trip: TripDto
    weak var delegate: BudgetDistributionViewModelDelegate?
    
    init(
        tripData: CreateTripData,
        trip: TripDto,
        participants: [String],
        tripService: TripServicing = TripService(),
        categoryService: CategoryServicing = CategoryService()
    ) {
        self.tripData = tripData
        self.trip = trip
        self.participants = participants
        self.tripService = tripService
        self.categoryService = categoryService
        self.totalBudget = tripData.totalBudget ?? 0
        self.state = .content(tripData)
    }
    
    func trigger(_ intent: BudgetDistributionViewIntent) {
        switch intent {
        case .onDidLoad:
            break
        case .toggleCategory(let category):
            toggleCategory(category)
        case .updatePercentage(let category, let value):
            updatePercentage(for: category, value: value)
        case .createTrip:
            Task { await createTrip() }
        }
    }
    
    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
            categoryPercentages.removeValue(forKey: category)
        } else {
            selectedCategories.insert(category)
            categoryPercentages[category] = 0
        }
        updateReadyStatus()
    }
    
    private func updatePercentage(for category: String, value: Double) {
        categoryPercentages[category] = value
        updateReadyStatus()
    }
    
    private func updateReadyStatus() {
        let allCategoriesHaveValues = selectedCategories.allSatisfy { category in
            guard let percentage = categoryPercentages[category] else { return false }
            return percentage > 0
        }
        
        let hasSelectedCategories = !selectedCategories.isEmpty
        
        isReadyToProceed = allCategoriesHaveValues && hasSelectedCategories
    }
    
    func getMaxAllowedPercentage(for category: String) -> Double {
        let currentTotal = totalPercentage
        if let existingPercentage = categoryPercentages[category] {
            return 100 - (currentTotal - existingPercentage)
        }
        return 100 - currentTotal
    }
    
    private func createTrip() async {
        do {
            state = .loading
            
            let existingCategories = try await categoryService.getAllCategories()
            var existingCategoryMap = Dictionary(
                uniqueKeysWithValues: existingCategories.map { ($0.name, $0.id!) }
            )
            
            for categoryName in selectedCategories {
                if existingCategoryMap[categoryName] == nil {
                    do {
                        let newCategory = try await categoryService.createCategory(
                            CreateCategoryRequestDto(
                                name: categoryName,
                                description: nil,
                                iconUrl: nil
                            )
                        )
                        if let id = newCategory.id {
                            existingCategoryMap[categoryName] = id
                        }
                    } catch {
                        self.error = "Ошибка при создании категории \(categoryName): \(error.localizedDescription)"
                        state = .error("Ошибка при создании категории \(categoryName)")
                        return
                    }
                }
            }
            
            for categoryName in selectedCategories {
                guard let categoryId = existingCategoryMap[categoryName],
                      let percentage = categoryPercentages[categoryName] else {
                    continue
                }
                
                let categoryBudget = Double(totalBudget) * (percentage / 100.0)
                do {
                    try await tripService.addTripCategory(
                        tripId: trip.id,
                        categoryId: categoryId,
                        budget: categoryBudget
                    )
                } catch {
                    self.error = "Ошибка при добавлении категории \(categoryName): \(error.localizedDescription)"
                    state = .error("Ошибка при добавлении категории \(categoryName)")
                    return
                }
            }
            
            state = .content(tripData)
            delegate?.budgetDistributionViewModelDidFinish(trip)
        } catch {
            self.error = error.localizedDescription
            state = .error(error.localizedDescription)
        }
    }
} 
