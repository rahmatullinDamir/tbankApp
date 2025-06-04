import UIKit

protocol SettingsCoordinating: AnyObject {
    func showSettings()
}

final class SettingsViewCoordinator: Coordinator, SettingsCoordinating {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSettings()
    }
    
    func showSettings() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        viewController.title = "Настройки"
        navigationController.pushViewController(viewController, animated: true)
    }
} 
