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
    let textField: CustomTextField
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.tiny.value)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    var text: String? {
        textField.text
    }
    
    var textPublisher: AnyPublisher<String?, Never> {
        textField.textPublisher
    }

    init(textField: CustomTextField) {
        self.textField = textField
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.textField = CustomTextField()
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        addSubview(errorLabel)
        
        textField.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(Padding.small.value)
            make.leading.trailing.equalToSuperview().inset(Padding.default.value)
            make.bottom.equalToSuperview()
        }
    }
    
    func showError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
    }
}
