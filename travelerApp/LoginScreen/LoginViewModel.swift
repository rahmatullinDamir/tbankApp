//
//  LoginViewModel.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.04.25.
//

import Foundation
import Combine

protocol LoginViewModeling: ViewModel where State == LoginViewState, Intent == LoginViewIntent {}

protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelDidRequestRegistration()
}

final class LoginViewModel: LoginViewModeling {
    @Published private(set) var state: LoginViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    weak var delegate: LoginViewModelDelegate?
    private(set) var stateDidChange = ObservableObjectPublisher()
    
    func trigger(_ intent: LoginViewIntent) {
        switch intent {
        case .onDidLoad: break
            
        case .onReload:
            state = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.state = .content("Данные перезагружены")
            }
            
        case .onClose: break
            
        case .onLogin(phoneNumber: let phoneNumber, password: let password):
            state = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                if phoneNumber.isEmpty || password.isEmpty {
                    self?.state = .error("Неверный номер телефона или пароль")
                } else {
                    self?.state = .content("Успешный вход")
                }
                
            }
            break
        case .onShowRegistration:
            print("showRegistration")
            delegate?.loginViewModelDidRequestRegistration()
        }
    }
}
