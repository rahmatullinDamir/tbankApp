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
        registrationButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let phoneNumber = self.phoneNumberTextField.text ?? ""
            let name = self.nameTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            let confirmPassword = self.confirmPasswordTextField.text ?? ""

            self.viewModel.trigger(.onRegisterTapped(phone: phoneNumber, name: name, password: password))
        }, for: .touchUpInside)
    }

    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: [
            phoneNumberTextField,
            nameTextField,
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

    private lazy var phoneNumberTextField: CustomTextField = {
        return CustomTextField(placeholder: "Номер телефона", keyboardType: .phonePad)
    }()

    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Имя")
        textField.delegate = self
        textField.returnKeyType = .next
        return textField
    }()

    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Пароль", keyboardType: .default)
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.returnKeyType = .next
        return textField
    }()

    private lazy var confirmPasswordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Подтверждение пароля", keyboardType: .default)
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
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

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()

            // Получаем значения текстовых полей
            let password = passwordTextField.text ?? ""
            let confirmPassword = confirmPasswordTextField.text ?? ""
            

            // Проверяем совпадение паролей
            if !password.isEmpty && password == confirmPassword {
                registrationButton.sendActions(for: .touchUpInside)
            } else {
                print("Пароли не совпадают")
                // Можно показать alert или ошибку под полем
            }
        }

        return true
    }
}

// MARK: - Touch handling
extension RegisterViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
