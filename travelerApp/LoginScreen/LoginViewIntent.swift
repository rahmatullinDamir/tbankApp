//
//  LoginViewIntent.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 27.04.25.
//

enum LoginViewIntent {
    case onDidLoad
    case onLogin(phoneNumber: String, password: String)
    case onClose
    case onReload
}
