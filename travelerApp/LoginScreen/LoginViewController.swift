//
//  ViewController.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 21.04.25.
//

import UIKit
import Combine
import SnapKit

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
        viewModel.stateDidChange.sink { [weak self] _ in
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
    
    private func render() {
        switch viewModel.state {
        case .loading:
            CustomLoadingManager.shared.show(on: view, with: "Загрузка данных...")
            
        case .content(let data):
            CustomLoadingManager.shared.hide()
            print("Content loaded: \(data)")
            
        case .error(let message):
            CustomLoadingManager.shared.hide()
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
    
    private lazy var phoneNumberTextField: CustomTextField = {
        return CustomTextField(placeholder: "Номер телефона", keyboardType: .phonePad)
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Пароль", keyboardType: .default)
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var loginButton: CustomActionButton = {
        return CustomActionButton(title: "Войти")
    }()
    
    private lazy var registerButton: CustomActionButton = {
        return CustomActionButton.linkButton(title: "Нет аккаунта? Зарегистрируйтесь") { [weak self] in
            print("register")
            self?.viewModel.trigger(.onShowRegistration)
        }
    }()
    
}

private extension CGFloat {
    static let stackViewSpacing: CGFloat = 16
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let phoneNumber = self.phoneNumberTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        self.viewModel.trigger(.onLogin(phoneNumber: phoneNumber, password: password))
        return true
    }
}
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
