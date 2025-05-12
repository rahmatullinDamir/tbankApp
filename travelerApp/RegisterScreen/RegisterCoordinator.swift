//
//  RegisterViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//
import UIKit

class RegisterCoordinator: BaseCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let viewModel = RegisterViewModel()
        viewModel.delegate = self
        let viewController = RegisterViewController(viewModel: viewModel)
        
        viewController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
extension RegisterCoordinator: RegisterViewModelDelegate {
    func registerViewModelDidRequestLogin() {
        navigationController.popViewController(animated: true)
//        removeChild(self) убрать ссылку из координатора рутового
    }
}
