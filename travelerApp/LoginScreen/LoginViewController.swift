//
//  ViewController.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 21.04.25.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    private let viewModel: any LoginViewModeling
    private var bag: Set<AnyCancellable> = []
    
    init(viewModel: any LoginViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureIO() {
        viewModel.stateDidChange.sink { [weak self] in
            self?.render()
        }
        .store(in: &bag)
        
        loginButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let phoneNumber = self.phoneNumberTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            self.viewModel.trigger(.onLogin(phoneNumber: phoneNumber, password: password))
        }, for: .touchUpInside)
    }
    
    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: [phoneNumberTextField, passwordTextField,
                                                       loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = CGFloat.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.default.value),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.default.value)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -Padding.big.value),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.default.value),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.default.value)
        ])
    }
    
    private func render() {
        switch viewModel.state {
        case .loading:
            LoadingManager.shared.show(on: view, with: "Загрузка данных...")
            
        case .content(let data):
            LoadingManager.shared.hide()
            print("Content loaded: \(data)")
            
        case .error(let message):
            LoadingManager.shared.hide()
            print("Error: \(message)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureIO()
        configureUI()
        viewModel.trigger(.onDidLoad)
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Вход"

        titleLabel.font = UIFont(name: FontFamilies.robotoMedium.value, size: FontConstants.header.value)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
                
        return titleLabel
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        let phoneNumberTextField = UITextField()
        phoneNumberTextField.placeholder = "Номер телефона"
        phoneNumberTextField.borderStyle = .roundedRect
        phoneNumberTextField.autocapitalizationType = .none
        phoneNumberTextField.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        phoneNumberTextField.keyboardType = .namePhonePad
        /// phoneNumberTextField.keyboardType = .phonePad хз как лучше чтобы была раскладка для ввода цифр номера или чтобы можно было нажать next и перейти к password??
        phoneNumberTextField.returnKeyType = .next
        phoneNumberTextField.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: 0.03)
        phoneNumberTextField.layer.cornerRadius = CGFloat.cornerRadius
        phoneNumberTextField.borderStyle = .none
        
        phoneNumberTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leftSpace, height: 0))
        phoneNumberTextField.leftViewMode = .always
        
        phoneNumberTextField.delegate = self
        phoneNumberTextField.heightAnchor.constraint(equalToConstant: CGFloat.height).isActive = true
        return phoneNumberTextField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Пароль"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        passwordTextField.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: 0.03)
        passwordTextField.layer.cornerRadius = CGFloat.cornerRadius
        passwordTextField.borderStyle = .none
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leftSpace, height: 0))
        passwordTextField.leftViewMode = .always
           
        passwordTextField.delegate = self
        passwordTextField.heightAnchor.constraint(equalToConstant: CGFloat.height).isActive = true
        return passwordTextField
    }()
    
    private lazy var loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        loginButton.setTitleColor(UIColor(hex: CustomColors.black.value), for: .normal)
        loginButton.backgroundColor = UIColor(hex: CustomColors.yellow.value)
        loginButton.heightAnchor.constraint(equalToConstant: CGFloat.height).isActive = true
        loginButton.layer.cornerRadius = CGFloat.cornerRadius
        return loginButton
    }()
    
    private lazy var registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Нет аккаунта? Зарегистрируйтесь", for: .normal)
        registerButton.setTitleColor(UIColor(hex: CustomColors.blue.value), for: .normal)
        registerButton.isUserInteractionEnabled = true
        registerButton.titleLabel?.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        registerButton.addAction(
        UIAction(handler: { [weak self] _ in
            self?.didTapRegister()
        }), for: .touchUpInside)
        return registerButton
    }()
    
    private func didTapRegister() {
        print("Переход к экрану регистрации")
    }
}

private extension CGFloat {
    static let cornerRadius: CGFloat = 16
    static let height: CGFloat = 60
    static let leftSpace: CGFloat = 16
    static let stackViewSpacing: CGFloat = 16
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case phoneNumberTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            let phoneNumber = self.phoneNumberTextField.text ?? ""
            let password = self.passwordTextField.text ?? ""
            self.viewModel.trigger(.onLogin(phoneNumber: phoneNumber, password: password))
        default:
            break
        }
        return true
    }
}
