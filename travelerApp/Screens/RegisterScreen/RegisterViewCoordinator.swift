//
//  RegisterViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//
import UIKit

protocol RegisterCoordinatorDelegate: AnyObject {
    func registerCoordinatorDidFinishRegistration(with authResponse: AuthResponse)
}

final class RegisterViewCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    weak var delegate: RegisterCoordinatorDelegate?
    
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
        showRegister()
    }
    
    private func showRegister() {
        let viewController = moduleFactory.makeRegisterModule(coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension RegisterViewCoordinator: RegisterViewModelDelegate {
    func registerViewModelDidRequestLogin() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
    
    func registerViewModelDidRegisterSuccessfully(_ authResponse: AuthResponse) {
        delegate?.registerCoordinatorDidFinishRegistration(with: authResponse)
    }
}
