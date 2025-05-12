//
//  RootCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 29.04.25.
//
import UIKit

class RootCoordinator: BaseCoordinator {
    private let window: UIWindow

    private let navigationController: UINavigationController

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    override func start() {
        let loginCoordinator = LoginViewCoordinator(navigationController: navigationController)
        addChild(loginCoordinator)
        loginCoordinator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func showSettings() {
        let coordinator = SettingsCoordinator()
        coordinator.parent = self
        addChild(coordinator)
        coordinator.start()
    }
}
