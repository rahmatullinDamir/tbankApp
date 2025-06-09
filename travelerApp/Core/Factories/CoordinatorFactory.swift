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
    
    func makeCreateTripCoordinator(navigationController: UINavigationController) -> CreateTripViewCoordinator {
        CreateTripViewCoordinator(navigationController: navigationController)
    }
    
    func makeProfileCoordinator(navigationController: UINavigationController, authResponse: AuthResponse) -> ProfileViewCoordinator {
        ProfileViewCoordinator(navigationController: navigationController, authResponse: authResponse)
    }
    
    func makeTripListCoordinator(navigationController: UINavigationController, authResponse: AuthResponse) -> TripListViewCoordinator {
        TripListViewCoordinator(navigationController: navigationController, authResponse: authResponse)
    }
}
