//
//  ActionButton.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 10.05.25.
//

import UIKit

// MARK: - ActionButton
class CustomActionButton: UIButton {
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    convenience init(title: String) {
        self.init(type: .system)
        setupButton(title: title)
    }

    convenience init(title: String, height: CGFloat = LayoutConstants.defaultButtonHeight) {
        self.init(type: .system)
        setupButton(title: title, height: height)
    }
    
    convenience init(title: String, backgroundColor: UIColor, titleColor: UIColor, height: CGFloat = LayoutConstants.defaultButtonHeight) {
        self.init(type: .system)
        setupButton(title: title, height: height)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
    }

    static func linkButton(title: String, action: @escaping () -> Void) -> CustomActionButton {
        let button = CustomActionButton(
            title: title,
            backgroundColor: .clear,
            titleColor: UIColor(hex: CustomColors.blue.value)
        )
        
        button.titleLabel?.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        
        return button
    }
    // MARK: - Настройка кнопки

    private func setupButton(title: String = "", height: CGFloat = LayoutConstants.defaultButtonHeight) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: FontFamilies.robotoRegular.value, size: FontConstants.regular.value)
        self.setTitleColor(UIColor(hex: CustomColors.black.value), for: .normal)
        self.backgroundColor = UIColor(hex: CustomColors.yellow.value)

        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.layer.cornerRadius = LayoutConstants.defaultCornerRadius
    }
}
