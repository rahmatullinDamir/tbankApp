//
//  LoginValidator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 17.05.25.
//

import Foundation

protocol LoginValidating {
    func validate(phoneNumber: String?) -> String?
    func validate(password: String?) -> String?
}

struct LoginValidator: LoginValidating {
    func validate(phoneNumber: String?) -> String? {
        guard let phone = phoneNumber else { return nil }
        if !PhoneNumber.isValid(phone) {
            return "Неверный формат номера"
        }
        return nil
    }

    func validate(password: String?) -> String? {
        guard let password = password else { return nil }
        if password.isEmpty {
            return "Пароль не может быть пустым"
        }
        if password.count < 6 {
            return "Пароль слишком короткий"
        }
        return nil
    }
}
