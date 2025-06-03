//
//  RegisterViewController.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//

import UIKit
import Combine

class RegisterViewController: UIViewController {
    private let viewModel: any RegisterViewModelling
    private var bag: Set<AnyCancellable> = []

    init(viewModel: any RegisterViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureIO() {
        bindFields()
        
        registrationButton.addAction(
            UIAction { [weak self] _ in
            guard let self = self else { return }
            let phoneNumber = self.phoneNumberTextField.text ?? ""
            let name = self.nameTextField.text ?? ""
            let surname = self.surnnameTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            self.viewModel.trigger(.onRegisterTapped(phone: phoneNumber, name: name, surname: surname, password: password))
            },
            for: .touchUpInside)
    }
    
    func bindFields() {
        

        viewModel.isFormValidPublisher
               .receive(on: DispatchQueue.main)
               .assign(to: \.isEnabled, on: registrationButton)
               .store(in: &bag)
        
        phoneNumberTextField.textPublisher.map { rawText in
            let digits = PhoneNumberFormatter.digits(from: rawText)
            return PhoneNumberFormatter.applyMask(to: digits)
        }
        .sink { [weak self] formattedNumber in
            self?.phoneNumberTextField.textField.text = formattedNumber
            self?.viewModel.trigger(.onUpdatePhoneNumber(text: formattedNumber))
        }
        .store(in: &bag)

        nameTextField.textPublisher.sink { [weak self] name in
            self?.viewModel.trigger(.onUpdateName(text: name))
        }
        .store(in: &bag)
        
        surnnameTextField.textPublisher.sink { [weak self] surname in
            self?.viewModel.trigger(.onUpdateSurname(text: surname))
        }
        .store(in: &bag)
        
        passwordTextField.textPublisher.sink { [weak self] password in
            self?.viewModel.trigger(.onUpdatePassword(text: password))
        }
        .store(in: &bag)
        
        Publishers.CombineLatest(passwordTextField.textPublisher, confirmPasswordTextField.textPublisher)
            .sink { [weak self] (originalPassword, confirmedPassword) in
                self?.viewModel.trigger(.onUpdateConfirmPassword(originalPassword: originalPassword, confirmPassword: confirmedPassword))
            }
            .store(in: &bag)
        
        Publishers.CombineLatest(
            viewModel.phoneNumberPublisher,
            viewModel.phoneNumberErrorPublisher
        )
        .receive(on: DispatchQueue.main)
        .filter { phoneNumber, error in
            (phoneNumber.count == 18) && error == nil
        }
        .sink { [weak self] _, _ in
            self?.nameTextField.textField.becomeFirstResponder()
        }
        .store(in: &bag)
        
        viewModel.phoneNumberErrorPublisher.sink { [weak self] error in
            self?.phoneNumberTextField.showError(error)
        }
        .store(in: &bag)
        
        viewModel.nameErrorPublisher.sink { [weak self] error in
            self?.nameTextField.showError(error)
        }
        .store(in: &bag)
        
        viewModel.surnameErrorPublisher.sink { [weak self] error in
            self?.surnnameTextField.showError(error)
        }
        .store(in: &bag)
        
        viewModel.passwordErrorPublisher.sink { [weak self] error in
            self?.passwordTextField.showError(error)
        }
        .store(in: &bag)
        
        viewModel.confirmErrorPublisher.sink { [weak self] error in
            self?.confirmPasswordTextField.showError(error)
        }
        .store(in: &bag)
    }
    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: [
            phoneNumberTextField,
            nameTextField,
            surnnameTextField,
            passwordTextField,
            confirmPasswordTextField,
            registrationButton,
            loginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-Padding.default.value)
            make.leading.equalTo(view.snp.leading).offset(Padding.default.value)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(view.snp.trailing).offset(-Padding.default.value)
        }
    }

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Регистрация"
        
        titleLabel.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.header.value)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        
        return titleLabel
    }()

    private lazy var phoneNumberTextField: ValidatedTextField = {
        let field = ValidatedTextField(CustomTextField(placeholder: "Номер телефона", keyboardType: .phonePad))
        return field
    }()

    private lazy var nameTextField: ValidatedTextField = {
        let field = ValidatedTextField(CustomTextField(placeholder: "Имя"))
        field.textField.delegate = self
        field.textField.returnKeyType = .next
        
        return field
    }()
    private lazy var surnnameTextField: ValidatedTextField = {
        let field = ValidatedTextField(CustomTextField(placeholder: "Фамилия"))
        field.textField.delegate = self
        field.textField.returnKeyType = .next
        
        return field
    }()

    private lazy var passwordTextField: ValidatedTextField = {
        let field = ValidatedTextField(CustomTextField(placeholder: "Пароль", keyboardType: .default))
        field.textField.isSecureTextEntry = true
        field.textField.delegate = self
        field.textField.returnKeyType = .next
        return field
    }()

    private lazy var confirmPasswordTextField: ValidatedTextField = {
        let field = ValidatedTextField(CustomTextField(placeholder: "Подтверждение пароля", keyboardType: .default))
        field.textField.isSecureTextEntry = true
        field.textField.delegate = self
        field.textField.returnKeyType = .done
        return field
    }()

    private lazy var registrationButton: CustomActionButton = {
        return CustomActionButton(title: "Зарегистрироваться")
    }()

    private lazy var loginButton: CustomActionButton = {
        return CustomActionButton.linkButton(title: "Уже есть аккаунт? Войдите") { [weak self] in
            self?.viewModel.trigger(.onLoginTapped)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureIO()
        configureUI()
        viewModel.trigger(.onDidLoad)
    }
}

private extension CGFloat {
    static let stackViewSpacing: CGFloat = 16
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard registrationButton.isEnabled else { return false }
        
        if textField == nameTextField.textField {
            surnnameTextField.textField.becomeFirstResponder()
        } else if textField == surnnameTextField.textField {
            passwordTextField.textField.becomeFirstResponder()
        } else if textField == passwordTextField.textField {
            confirmPasswordTextField.textField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField.textField {
            let phoneNumber = self.phoneNumberTextField.text ?? ""
            let name = self.nameTextField.text ?? ""
            let surname = self.surnnameTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            self.viewModel.trigger(.onRegisterTapped(
                phone: phoneNumber, name: name, surname: surname, password: password))
        }

        return true
    }
}

extension RegisterViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
