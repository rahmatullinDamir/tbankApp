//
//  RegisterViewModel.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//

import Combine
protocol RegisterViewModelling: ViewModel where State == RegisterViewState, Intent == RegisterViewIntent {}

protocol RegisterViewModelDelegate: AnyObject {
    func registerViewModelDidRequestLogin()
}


class RegisterViewModel: RegisterViewModelling {
    @Published private(set) var state: RegisterViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    private(set) var stateDidChange = ObservableObjectPublisher()
    weak var delegate: RegisterViewModelDelegate?
    
    func trigger(_ intent: RegisterViewIntent) {
        switch intent {
        case .onDidLoad:
            break
        case .onLoginTapped:
            delegate?.registerViewModelDidRequestLogin()
        case .onRegisterTapped(phone: let phone, name: let name, password: let password):
            print("Registerrrr")
        }
        
        
    }
}
