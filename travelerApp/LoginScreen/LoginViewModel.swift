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

    func validateFields()
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
    
    var phoneNumberPublisher: AnyPublisher<String, Never> {
        $phoneNumber.eraseToAnyPublisher()
    }
    
    var phoneNumberErrorPublisher: AnyPublisher<String?, Never> {
        $phoneNumberError.eraseToAnyPublisher()
    }

    var passwordErrorPublisher: AnyPublisher<String?, Never> {
        $passwordError.eraseToAnyPublisher()
    }

    // MARK: - Validation Logic
    func validateFields() {
        phoneNumberError = validator.validate(phoneNumber: phoneNumber)
        passwordError = validator.validate(password: password)
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
            print("showRegistration")
            delegate?.loginViewModelDidRequestRegistration()
            
        case .onUpdatePassword(text: let text):
            self.password = text ?? ""
            validateFields()
            
        case .onUpdatePhoneNumber(text: let text):
            self.phoneNumber = text ?? ""
            validateFields()
        }
    }
}
