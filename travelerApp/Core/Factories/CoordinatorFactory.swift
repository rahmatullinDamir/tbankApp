//
//  CoordinatorFactory.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.05.25.
//

import UIKit


class CoordinatorFactory {
    func makeLoginCoordinator(navigationController: UINavigationController) -> LoginViewCoordinator {
        LoginViewCoordinator(navigationController: navigationController)
    }
    
    func makeRegisterCoordinator(navigationController: UINavigationController) -> RegisterViewCoordinator {
        RegisterViewCoordinator(navigationController: navigationController)
    }
}
