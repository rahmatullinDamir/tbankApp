//
//  RootCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//
import UIKit

class RootCoordinator: Coordinator {
    var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    private let navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.navigationController = UINavigationController()
        self.window = window
    }
    
    func start() {
        let loginCoordinator = LoginViewCoordinator(navigationController: navigationController)
            addChild(loginCoordinator)
            loginCoordinator.start()
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
    }
    
    func showSettings() {
        let coordinator = SettingsCoordinator()
        addChild(coordinator)
        coordinator.start()
    }
}
