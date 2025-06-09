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

    var phoneNumberPublisher: AnyPublisher<String, Never> { get}
    var phoneNumberErrorPublisher: AnyPublisher<String?, Never> { get }
    var passwordErrorPublisher: AnyPublisher<String?, Never> { get }
    var isFormValidPublisher: AnyPublisher<Bool, Never> { get }
}

protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelDidRequestRegistration()
    func loginViewModelDidLoginSuccessfully(_ authResponse: AuthResponse)
}

final class LoginViewModel: LoginViewModeling {
    private let validator: LoginValidating
    private let authService: AuthServicing

    init(
        validator: LoginValidating = LoginValidator(),
        authService: AuthServicing = AuthService()
    ) {
        self.validator = validator
        self.authService = authService
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
            
            login(phoneNumber: phoneNumber, password: password)
            
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

    private func login(phoneNumber: String, password: String) {
        Task {
            do {
                let credentials = LoginDto(phoneNumber: phoneNumber, password: password)
                let response = try await authService.login(with: credentials)
                await MainActor.run { [weak self] in
                    self?.delegate?.loginViewModelDidLoginSuccessfully(response)
                }
            } catch NetworkError.unauthorized, NetworkError.notFound {
                await MainActor.run { [weak self] in
                    self?.state = .error("Неверный номер телефона или пароль")
                }
            } catch NetworkError.noData {
                await MainActor.run { [weak self] in
                    self?.state = .error("Отсутствует подключение к интернету")
                }
            } catch NetworkError.serverError {
                await MainActor.run { [weak self] in
                    self?.state = .error("Сервер временно недоступен")
                }
            } catch {
                await MainActor.run { [weak self] in
                    print("Неизвестная ошибка: \(error.localizedDescription)")
                    self?.state = .error("Произошла ошибка. Попробуйте позже")
                }
            }
        }
    }
}
