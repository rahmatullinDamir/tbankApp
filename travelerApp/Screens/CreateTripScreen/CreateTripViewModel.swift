import Foundation
import Combine

protocol CreateTripViewModelDelegate: AnyObject {
    func createTripViewModelDidFinishCreating(_ trip: TripDto)
    func createTripViewModelDidCancel()
    func createTripViewModelDidRequestNextStep(_ tripData: CreateTripData)
}

protocol CreateTripViewModeling: ViewModel where State == CreateTripViewState, Intent == CreateTripViewIntent {
    var namePublisher: AnyPublisher<String, Never> { get }
    var nameErrorPublisher: AnyPublisher<String?, Never> { get }
    var startDateErrorPublisher: AnyPublisher<String?, Never> { get }
    var endDateErrorPublisher: AnyPublisher<String?, Never> { get }
    var budgetErrorPublisher: AnyPublisher<String?, Never> { get }
    var isFormValidPublisher: AnyPublisher<Bool, Never> { get }
}

final class CreateTripViewModel: CreateTripViewModeling {
    @Published private(set) var state: CreateTripViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    
    @Published private var name: String = ""
    @Published private var nameError: String?
    @Published private var startDateError: String?
    @Published private var endDateError: String?
    @Published private var budgetError: String?
    
    private var formData = CreateTripData()
    
    weak var delegate: CreateTripViewModelDelegate?
    
    private let validator: CreateTripValidating
    private let tripService: TripServicing
    
    init(
        validator: CreateTripValidating = CreateTripValidator(),
        tripService: TripServicing = TripService()
    ) {
        self.validator = validator
        self.tripService = tripService
    }
    
    var namePublisher: AnyPublisher<String, Never> {
        $name.eraseToAnyPublisher()
    }
    
    var nameErrorPublisher: AnyPublisher<String?, Never> {
        $nameError.eraseToAnyPublisher()
    }
    
    var startDateErrorPublisher: AnyPublisher<String?, Never> {
        $startDateError.eraseToAnyPublisher()
    }
    
    var endDateErrorPublisher: AnyPublisher<String?, Never> {
        $endDateError.eraseToAnyPublisher()
    }
    
    var budgetErrorPublisher: AnyPublisher<String?, Never> {
        $budgetError.eraseToAnyPublisher()
    }
    
    var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            $nameError,
            $startDateError,
            $endDateError,
            $budgetError
        )
        .map { nameError, startDateError, endDateError, budgetError -> Bool in
            let hasNoErrors = nameError == nil && startDateError == nil && endDateError == nil && budgetError == nil
            let allFieldsFilled = !self.formData.name.isEmpty &&
                self.formData.startDate != nil &&
                self.formData.endDate != nil &&
                self.formData.totalBudget != nil &&
                self.formData.totalBudget ?? 0 > 0
            
            return hasNoErrors && allFieldsFilled
        }
        .eraseToAnyPublisher()
    }
    
    func trigger(_ intent: CreateTripViewIntent) {
        switch intent {
        case .onDidLoad:
            state = .content(formData)
            
        case .updateName(let name):
            self.name = name
            formData.name = name
            nameError = validator.validate(name: name)
            validateForm()
            updateState()
            
        case .updateStartDate(let date):
            formData.startDate = date
            startDateError = validator.validate(startDate: date)
            endDateError = validator.validate(endDate: formData.endDate, startDate: date)
            validateForm()
            updateState()
            
        case .updateEndDate(let date):
            formData.endDate = date
            endDateError = validator.validate(endDate: date, startDate: formData.startDate)
            validateForm()
            updateState()
            
        case .updateBudget(let budget):
            formData.totalBudget = budget
            budgetError = validator.validate(budget: Double(budget))
            validateForm()
            updateState()
            
        case .updateCategories(let categories):
            formData.categories = categories
            validateForm()
            updateState()
            
        case .nextStep:
            if formData.isFormValid {
                delegate?.createTripViewModelDidRequestNextStep(formData)
            }
            
        case .cancel:
            delegate?.createTripViewModelDidCancel()
        }
    }
    
    private func validateForm() {
        formData.isFormValid = !formData.name.isEmpty &&
            formData.startDate != nil &&
            formData.endDate != nil &&
            formData.totalBudget != nil &&
            formData.totalBudget ?? 0 > 0 &&
            nameError == nil &&
            startDateError == nil &&
            endDateError == nil &&
            budgetError == nil
    }
    
    private func updateState() {
        state = .content(formData)
    }
    
    private func createTrip() async throws -> TripDto {
        let createDto = TripCreateDto(
            name: formData.name,
            startDate: formData.startDate ?? Date()
        )
        return try await tripService.createTrip(createDto)
    }
} 
