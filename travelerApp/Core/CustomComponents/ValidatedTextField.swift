//
//  ValidatedTextField.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 17.05.25.
//

import UIKit
import Combine
import SnapKit

class ValidatedTextField: UIView {
    var textField: CustomTextField
    let errorLabel = UILabel()

    // MARK: - Publishers
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .map { _ in self.textField.text }
            .eraseToAnyPublisher()
    }

    // MARK: - Инициализаторы
    override init(frame: CGRect) {
        self.textField = CustomTextField()
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        self.textField = CustomTextField()
        super.init(coder: coder)
        setup()
    }

    convenience init(_ textField: CustomTextField) {
        self.init(frame: .zero)
        self.textField = textField
        setup()
    }

    // MARK: - Настройка UI
    private func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        errorLabel.textColor = .red
        errorLabel.font = UIFont.systemFont(ofSize: FontConstants.regular.value)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        addSubview(errorLabel)

        textField.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Padding.default.value)
            make.top.equalTo(textField.snp.bottom).offset(Padding.small.value)
        }
    }

    var text: String? {
        textField.text
    }

    func showError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
    }
}
