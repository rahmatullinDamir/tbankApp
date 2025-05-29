//
//  RegisterViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//
import UIKit

class RegisterViewCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = RegisterViewModel()
        viewModel.delegate = self
        let viewController = RegisterViewController(viewModel: viewModel)
        
        viewController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
extension RegisterViewCoordinator: RegisterViewModelDelegate {
    func registerViewModelDidRequestLogin() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
}
