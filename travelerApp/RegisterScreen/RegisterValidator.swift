//
//  RegisterValidator.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 20.05.25.
//

import Foundation

protocol RegisterValidating {
    func validate(phoneNumber: String?) -> String?
    func validate(password: String?) -> String?
    func validate(name: String) -> String?
    func validate(surname: String) -> String?
    func validate(confirmPassword: String?, originalPassword: String?) -> String?
}
struct RegisterValidator: RegisterValidating {
    func validate(phoneNumber: String?) -> String? {
        guard let phone = phoneNumber else { return nil }
        if !PhoneNumberFormatter.isValid(phone) {
            return "Неверный формат номера"
        }
        return nil
    }
    func validate(password: String?) -> String? {
        guard let password = password, !password.isEmpty else {
            return "Пароль не может быть пустым"
        }

        if password.count < 8 {
            return "Пароль должен содержать минимум 8 символов"
        }

        // Регулярное выражение для проверки заглавных и строчных букв
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if !predicate.evaluate(with: password) {
            return "Пароль должен содержать заглавные и строчные буквы"
        }

        return nil
    }
    
    func validate(confirmPassword: String?, originalPassword: String?) -> String? {
        guard let confirmPassword = confirmPassword, let originalPassword = originalPassword else {
            return "Пароли не совпадают"
        }
        
        if confirmPassword != originalPassword {
            return "Пароли не совпадают"
        }
        
        return nil
    }
    
    func validate(name: String) -> String? {
        if name.count < 3 || name.count > 20 {
            return "Длина от 3 до 20 символов"
        }
        return nil
    }
    func validate(surname: String) -> String? {
        if surname.count < 3 || surname.count > 20 {
            return "Длина от 3 до 20 символов"
        }
        return nil
    }
}
