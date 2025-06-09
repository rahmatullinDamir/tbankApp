//
//  RootCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//
import UIKit

final class RootCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    private var authResponse: AuthResponse?
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        
        self.navigationController.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        self.navigationController.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")

        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -1000, vertical: 0),
            for: .default
        )
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
<<<<<<< Updated upstream
    func showSettings() {
        let coordinator = SettingsCoordinator()
        addChild(coordinator)
        coordinator.parentCoordinator = self
=======
    func start() {
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let coordinator = CoordinatorFactory().makeLoginCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    private func showMainScreen() {
        guard let authResponse = authResponse else {
            showLoginScreen()
            return
        }
        childCoordinators.removeAll()
        let coordinator = CoordinatorFactory().makeTripListCoordinator(navigationController: navigationController, authResponse: authResponse)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func handleLogout() {
        authResponse = nil
        childCoordinators.removeAll()
        navigationController.isNavigationBarHidden = true
        showLoginScreen()
    }
}

extension RootCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidFinishLogin(with authResponse: AuthResponse) {
        self.authResponse = authResponse
        showMainScreen()
    }
    
    func loginCoordinatorDidRequestRegistration() {
        navigationController.isNavigationBarHidden = true
        let coordinator = CoordinatorFactory().makeRegisterCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinator.delegate = self
        childCoordinators.append(coordinator)
>>>>>>> Stashed changes
        coordinator.start()
    }
}

extension RootCoordinator: RegisterCoordinatorDelegate {
    func registerCoordinatorDidFinishRegistration(with authResponse: AuthResponse) {
        self.authResponse = authResponse
        showMainScreen()
    }
}
