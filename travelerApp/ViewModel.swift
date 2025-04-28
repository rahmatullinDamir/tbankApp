//
//  ViewModelProtocol.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.04.25.
//

import Foundation
import Combine

protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Intent
 
    var state: State {get}
    var stateDidChange: ObservableObjectPublisher { get }
    func trigger(_ intent: Intent)
}
