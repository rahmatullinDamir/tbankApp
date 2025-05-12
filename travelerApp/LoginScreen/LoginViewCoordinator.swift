//
//  LoginViewCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//

import UIKit

// LoginViewCoordinator.swift

class LoginViewCoordinator: BaseCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        let viewModel = LoginViewModel()
        viewModel.delegate = self
        let viewController = LoginViewController(viewModel: viewModel)
        
        // Устанавливаем view controller как корневой в навигации
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    deinit {
          print("LoginViewCoordinator deinited") // 👈 Если это печатается раньше времени — проблема
      }
}
extension LoginViewCoordinator: LoginViewModelDelegate {
    func loginViewModelDidRequestRegistration() {
        print("start!")
        let registerCoordinator = RegisterCoordinator(navigationController: navigationController)
        addChild(registerCoordinator)
        registerCoordinator.start()
    }
}
