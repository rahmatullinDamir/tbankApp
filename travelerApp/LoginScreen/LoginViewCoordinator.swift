//
//  LoginViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//

import UIKit

class LoginViewCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ModuleFactory().makeLoginModule(coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
extension LoginViewCoordinator: LoginViewModelDelegate {
    func loginViewModelDidRequestRegistration() {
        let registerCoordinator = CoordinatorFactory().makeRegisterCoordinator(navigationController: navigationController)
        addChild(registerCoordinator)
        registerCoordinator.start()
    }
}
