import UIKit

protocol TripListCoordinating: Coordinator {
    func showCreateTrip()
    func showTripDetails(_ trip: TripDto)
}

final class TripListViewCoordinator: TripListCoordinating {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    private let navigationController: UINavigationController
    private let authResponse: AuthResponse
    private let moduleFactory: ModuleFactory
    private let coordinatorFactory: CoordinatorFactory
    
    private lazy var tabBarController: MainTabBarController = {
        let tabBarController = MainTabBarController()
        tabBarController.mainDelegate = self
        return tabBarController
    }()
    
    init(
        navigationController: UINavigationController,
        authResponse: AuthResponse,
        moduleFactory: ModuleFactory = ModuleFactory(),
        coordinatorFactory: CoordinatorFactory = CoordinatorFactory()
    ) {
        self.navigationController = navigationController
        self.authResponse = authResponse
        self.moduleFactory = moduleFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start() {
        showTripList()
    }
    
    func showTripList() {
        let tripListViewController = moduleFactory.makeTripListModule(coordinator: self, authResponse: authResponse)
        let tripListNavController = UINavigationController(rootViewController: tripListViewController)
        let profileViewController = moduleFactory.makeProfileModule(coordinator: self, authResponse: authResponse)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        
        tabBarController.setViewControllers(
            [tripListNavController, UIViewController(), profileNavController],
            animated: false
        )
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    func showCreateTrip() {
        let coordinator = coordinatorFactory.makeCreateTripCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func showTripDetails(_ trip: TripDto) {
        let viewController = moduleFactory.makeTripDetailsModule(coordinator: self, trip: trip, title: trip.name)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showExpenses(for trip: TripDto) {
        print("show expenses")
    }
    
    func showNewTrip() {
        navigationController.isNavigationBarHidden = false
        let coordinator = coordinatorFactory.makeCreateTripCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension TripListViewCoordinator: TripListViewModelDelegate {
    func tripListViewModelDidRequestOpenNotifications() {
        navigationController.isNavigationBarHidden = false
        let viewController = moduleFactory.makeNotificationsModule(coordinator: self)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func tripListViewModelDidSelectTrip(_ trip: TripDto) {
        showTripDetails(trip)
    }
    
    func tripListViewModelDidRequestNewTrip() {
        showNewTrip()
    }
    
    func tripListViewModelDidRequestProfile() {
        tabBarController.selectedIndex = 2
    }
}

extension TripListViewCoordinator: ProfileViewModelDelegate {
    func profileViewModelDidRequestLogout() {
        (parentCoordinator as? RootCoordinator)?.handleLogout()
    }
}

extension TripListViewCoordinator: MainTabBarControllerDelegate {
    func mainTabBarControllerDidTapPlusButton() {
        showNewTrip()
    }
}

extension TripListViewCoordinator: CreateTripCoordinatorDelegate {
    func createTripCoordinatorDidFinishCreating(_ trip: TripDto) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.popViewController(animated: true)
            self?.childCoordinators.removeAll { $0 is CreateTripViewCoordinator }
        }
    }
    
    func createTripCoordinatorDidCancel() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.popViewController(animated: true)
            self?.childCoordinators.removeAll { $0 is CreateTripViewCoordinator }
        }
    }
}

extension TripListViewCoordinator: TripDetailsViewModelDelegate {
    func tripDetailsViewModelDidFinish() {
        navigationController.popViewController(animated: true)
    }
    
    func tripDetailsViewModelDidRequestAddExpense(_ tripId: Int64) {
        let viewController = moduleFactory.makeExpenseAddModule(coordinator: self, tripId: tripId, title: "Детали поездки")
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension TripListViewCoordinator: ExpenseAddViewModelDelegate {
    func expenseAddViewModelDidFinish() {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: true)
        }
       
    }
}

extension TripListViewCoordinator: NotificationsViewModelDelegate {
    func notificationsViewModelDidFinish() {
        navigationController.popViewController(animated: true)
    }
} 
 
