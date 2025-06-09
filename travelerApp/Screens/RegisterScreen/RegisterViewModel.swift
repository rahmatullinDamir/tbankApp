//
//  RegisterViewModel.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//

import Combine
import Foundation

protocol RegisterViewModelling: ViewModel where State == RegisterViewState, Intent == RegisterViewIntent {
    var phoneNumber: String {get}
    var password: String {get}
    var confirmPassword: String {get}
    var name: String {get}
    var surname: String {get}
    
    // MARK: - Publishers protocol
    var phoneNumberPublisher: AnyPublisher<String, Never> { get }
    var phoneNumberErrorPublisher: AnyPublisher<String?, Never> { get }
    var passwordErrorPublisher: AnyPublisher<String?, Never> { get }
    var confirmErrorPublisher: AnyPublisher<String?, Never> { get }
    var nameErrorPublisher: AnyPublisher<String?, Never> { get }
    var surnameErrorPublisher: AnyPublisher<String?, Never> { get }
    var isFormValidPublisher: AnyPublisher<Bool, Never> { get }
}

protocol RegisterViewModelDelegate: AnyObject {
    func registerViewModelDidRequestLogin()
    func registerViewModelDidRegisterSuccessfully(_ authResponse: AuthResponse)
}

class RegisterViewModel: RegisterViewModelling {
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = ""
    @Published var surname: String = ""
    
    @Published private(set) var phoneNumberError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var confirmError: String?
    @Published private(set) var nameError: String?
    @Published private(set) var surnameError: String?
    
    // MARK: - Publishers
    var isFormValidPublisher: AnyPublisher<Bool, Never> {
        let part1 = Publishers.CombineLatest3(
            $phoneNumber.map { !$0.isEmpty },
            $name.map { !$0.isEmpty },
            $surname.map { !$0.isEmpty }
        )
        .setFailureType(to: Never.self)

        let part2 = Publishers.CombineLatest(
            $password.map { !$0.isEmpty },
            $confirmPassword.map { !$0.isEmpty }
        )
        .setFailureType(to: Never.self)

        let allFieldsFilled = part1.combineLatest(part2)
            .map { (values: ((Bool, Bool, Bool), (Bool, Bool))) -> Bool in
                let ((phone, name, surname), (password, confirm)) = values
                return phone && name && surname && password && confirm
            }


        let errorPart1 = Publishers.CombineLatest3(
            $phoneNumberError.map { $0 == nil },
            $nameError.map { $0 == nil },
            $surnameError.map { $0 == nil }
        )
        .setFailureType(to: Never.self)

        let errorPart2 = Publishers.CombineLatest(
            $passwordError.map { $0 == nil },
            $confirmError.map { $0 == nil }
        )
        .setFailureType(to: Never.self)

        let noErrors = errorPart1.combineLatest(errorPart2)
            .map { (values: ((Bool, Bool, Bool), (Bool, Bool))) -> Bool in
                let ((phoneErr, nameErr, surnameErr), (passwordErr, confirmErr)) = values
                return phoneErr && nameErr && surnameErr && passwordErr && confirmErr
            }

        return Publishers.CombineLatest(allFieldsFilled, noErrors)
            .map { $0 && $1 }
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
    
    var confirmErrorPublisher: AnyPublisher<String?, Never> {
        $confirmError.eraseToAnyPublisher()
    }
    
    var nameErrorPublisher: AnyPublisher<String?, Never> {
        $nameError.eraseToAnyPublisher()
    }
    
    var surnameErrorPublisher: AnyPublisher<String?, Never> {
        $surnameError.eraseToAnyPublisher()
    }
    

    private let validator: RegisterValidating
    private let authService: AuthServicing
    
    init(
        validator: RegisterValidating = RegisterValidator(),
        authService: AuthServicing = AuthService()
    ) {
           self.validator = validator
        self.authService = authService
    }
    
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
        case .onUpdateName(text: let text):
            self.name = text ?? ""
            nameError = validator.validate(name: name)
        case .onUpdatePhoneNumber(text: let text):
            self.phoneNumber = text ?? ""
            phoneNumberError = validator.validate(phoneNumber: phoneNumber)
        
        case .onUpdateSurname(text: let text):
            self.surname = text ?? ""
            surnameError = validator.validate(surname: surname)
        case .onUpdatePassword(text: let text):
            self.password = text ?? ""
            passwordError = validator.validate(password: password)
        case .onUpdateConfirmPassword(originalPassword: let originalPassword, confirmPassword: let confirmPassword):
            self.password = originalPassword ?? ""
            self.confirmPassword = confirmPassword ?? ""
            confirmError = validator.validate(confirmPassword: confirmPassword, originalPassword: password)
            
        case .onRegisterTapped(phone: let phone, name: let name, surname: let surname, password: let password):
            state = .loading
            register(phone: phone, name: name, surname: surname, password: password)
        }
    }
    
    private func register(phone: String, name: String, surname: String, password: String) {
        Task {
            do {
                let form = RegistrationFormDto(
                    firstName: name,
                    lastName: surname,
                    phoneNumber: phone,
                    password: password
                )
                let response = try await authService.register(with: form)
                await MainActor.run { [weak self] in
                    self?.state = .success
                    self?.delegate?.registerViewModelDidRegisterSuccessfully(response)
                }
            } catch NetworkError.unauthorized, NetworkError.notFound {
                await MainActor.run { [weak self] in
                    self?.state = .error("Пользователь с таким номером телефона уже существует")
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
