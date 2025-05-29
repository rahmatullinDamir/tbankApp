//
//  ModuleFactory.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.05.25.
//

class ModuleFactory {
    func makeLoginModule(coordinator: LoginViewModelDelegate) -> LoginViewController {
        let viewModel = LoginViewModel()
        viewModel.delegate = coordinator
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeRegisterModule(coordinator: RegisterViewModelDelegate) -> RegisterViewController {
        let viewModel = RegisterViewModel()
        viewModel.delegate = coordinator
        let viewController = RegisterViewController(viewModel: viewModel)
        return viewController
    }
}
