//
//  RegisterViewIntent.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//

enum RegisterViewIntent {
    case onDidLoad
    case onLoginTapped
    case onRegisterTapped(phone: String, name: String, surname: String, password: String)
    case onUpdatePhoneNumber(text: String?)
    case onUpdateName(text: String?)
    case onUpdateSurname(text: String?)
    case onUpdatePassword(text: String?)
    case onUpdateConfirmPassword(originalPassword: String?, confirmPassword: String?)
}
