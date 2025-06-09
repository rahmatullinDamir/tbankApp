//
//  LoginViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//

import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func loginCoordinatorDidFinishLogin(with authResponse: AuthResponse)
    func loginCoordinatorDidRequestRegistration()
}

final class LoginViewCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    weak var delegate: LoginCoordinatorDelegate?
    
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactory
    
    init(
        navigationController: UINavigationController,
        moduleFactory: ModuleFactory = ModuleFactory()
    ) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
    func start() {
        showLogin()
    }
    
    private func showLogin() {
        let viewController = moduleFactory.makeLoginModule(coordinator: self)
        navigationController.setViewControllers([viewController], animated: true)
    }
}

extension LoginViewCoordinator: LoginViewModelDelegate {
    func loginViewModelDidLoginSuccessfully(_ authResponse: AuthResponse) {
        delegate?.loginCoordinatorDidFinishLogin(with: authResponse)
    }
    
    func loginViewModelDidRequestRegistration() {
        delegate?.loginCoordinatorDidRequestRegistration()
    }
}
