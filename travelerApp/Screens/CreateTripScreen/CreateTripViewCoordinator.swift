import UIKit

protocol CreateTripCoordinatorDelegate: AnyObject {
    func createTripCoordinatorDidFinishCreating(_ trip: TripDto)
    func createTripCoordinatorDidCancel()
}

final class CreateTripViewCoordinator: Coordinator {
    var parentCoordinator: (any Coordinator)?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: CreateTripCoordinatorDelegate?
    private var tripData: CreateTripData?
    private let moduleFactory: ModuleFactory
    
    init(
        navigationController: UINavigationController,
        moduleFactory: ModuleFactory = ModuleFactory()
    ) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
    func start() {
        let viewController = moduleFactory.makeCreateTripModule(coordinator: self, title: "Создание поездки")
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension CreateTripViewCoordinator: CreateTripViewModelDelegate {
    func createTripViewModelDidFinishCreating(_ trip: TripDto) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.createTripCoordinatorDidFinishCreating(trip)
        }
    }
    
    func createTripViewModelDidCancel() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.createTripCoordinatorDidCancel()
        }
    }
    
    func createTripViewModelDidRequestNextStep(_ tripData: CreateTripData) {
        self.tripData = tripData
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let viewController = moduleFactory.makeParticipantsModule(coordinator: self, tripData: tripData, title: "Cоздание поездки")
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
}

extension CreateTripViewCoordinator: ParticipantsViewModelDelegate {
    func participantsViewModelDidFinishSelectingParticipants(_ trip: TripDto, participants: [String]) {
        guard let tripData = self.tripData else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let viewController = moduleFactory.makeBudgetDistributionModule(
                coordinator: self,
                tripData: tripData,
                trip: trip,
                participants: participants,
                title: "Cоздание поездки"
            )
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
}

extension CreateTripViewCoordinator: BudgetDistributionViewModelDelegate {
    func budgetDistributionViewModelDidFinish(_ trip: TripDto) {
        delegate?.createTripCoordinatorDidFinishCreating(trip)
    }
} 
