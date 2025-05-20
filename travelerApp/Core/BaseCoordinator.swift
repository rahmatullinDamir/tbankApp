//
//  BaseCoordinator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 11.05.25.
//

protocol Coordinator: AnyObject {
    func start()
}

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    func start() {
        fatalError("Implement in subclass")
    }

    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    deinit {
        print("❌ \(type(of: self)) deinited")
    }
}
