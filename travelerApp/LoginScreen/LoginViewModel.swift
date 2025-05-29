//
//  LoginViewModel.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.04.25.
//

import Foundation
import Combine

protocol LoginViewModeling: ViewModel where State == LoginViewState, Intent == LoginViewIntent {
    var phoneNumber: String { get }
    var password: String { get }

    // MARK: - Publishers protocol
    var phoneNumberPublisher: AnyPublisher<String, Never> { get}
    var phoneNumberErrorPublisher: AnyPublisher<String?, Never> { get }
    var passwordErrorPublisher: AnyPublisher<String?, Never> { get }
    var isFormValidPublisher: AnyPublisher<Bool, Never> { get }
}

protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelDidRequestRegistration()
}

final class LoginViewModel: LoginViewModeling {
    private let validator: LoginValidating

    init(validator: LoginValidating = LoginValidator()) {
        self.validator = validator
    }
    
    @Published private(set) var state: LoginViewState = .loading {
        didSet {
            stateDidChange.send()
        }
    }
    
    weak var delegate: LoginViewModelDelegate?
    private(set) var stateDidChange = ObservableObjectPublisher()
    
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
      
    @Published private(set) var phoneNumberError: String?
    @Published private(set) var passwordError: String?

    // MARK: - Publishers
    
    var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            $phoneNumber.map { !$0.isEmpty },
            $password.map { !$0.isEmpty },
            $phoneNumberError.map { $0 == nil },
            $passwordError.map { $0 == nil }
        )
        .map { $0 && $1 && $2 && $3 }
        .eraseToAnyPublisher()
    }
    
    var phoneNumberPublisher: AnyPublisher<String, Never> {
        $phoneNumber.eraseToAnyPublisher()
    }
    
    var phoneNumberErrorPublisher: AnyPublisher<String?, Never> {
        $phoneNumberError.eraseToAnyPublisher()
    }

    var passwordErrorPublisher: AnyPublisher<String?, Never> {
        $passwordError.eraseToAnyPublisher()
    }
    
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
        case .onShowRegistration:
            delegate?.loginViewModelDidRequestRegistration()
            
        case .onUpdatePassword(text: let text):
            self.password = text ?? ""
            passwordError = validator.validate(password: password)
            
        case .onUpdatePhoneNumber(text: let text):
            self.phoneNumber = text ?? ""
            phoneNumberError = validator.validate(phoneNumber: phoneNumber)
        }
    }
}
