import UIKit

protocol ProfileCoordinatorDelegate: AnyObject {
    func profileCoordinatorDidRequestLogout()
}

final class ProfileViewCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    weak var delegate: ProfileCoordinatorDelegate?
    
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactory
    private let authResponse: AuthResponse
    
    init(
        navigationController: UINavigationController,
        authResponse: AuthResponse,
        moduleFactory: ModuleFactory = ModuleFactory()
    ) {
        self.navigationController = navigationController
        self.authResponse = authResponse
        self.moduleFactory = moduleFactory
    }
    
    func start() {
        showProfile()
    }
    
    private func showProfile() {
        let viewController = moduleFactory.makeProfileModule(coordinator: self, authResponse: authResponse)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ProfileViewCoordinator: ProfileViewModelDelegate {
    func profileViewModelDidRequestLogout() {
        delegate?.profileCoordinatorDidRequestLogout()
    }
} 
