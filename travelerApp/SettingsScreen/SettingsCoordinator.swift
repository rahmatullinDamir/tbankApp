//
//  SettingsCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 11.05.25.
//

class SettingsCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    
    var childCoordinators: [any Coordinator] = []
    
    func start() {
    }
}
