//
//  CustomTextField.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 10.05.25.
//

import UIKit

// MARK: - CustomTextField
class CustomTextField: UITextField {
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    convenience init(placeholder: String, keyboardType: UIKeyboardType = .default) {
        self.init()
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        setupTextField()
    }

    private func setupTextField() {
        self.borderStyle = .none
        self.autocapitalizationType = .none
        self.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        self.backgroundColor = UIColor(hex: CustomColors.grey.value, alpha: 0.03)
        self.layer.cornerRadius = LayoutConstants.defaultCornerRadius
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: LayoutConstants.leftSpace, height: 0))
        self.leftViewMode = .always

        self.heightAnchor.constraint(equalToConstant: LayoutConstants.defaultTextFieldHeight).isActive = true
    }
}
