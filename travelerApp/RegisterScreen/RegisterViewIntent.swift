//
//  RegisterViewIntent.swift
//  travelerApp
//
//  Created by Damir Rakhmatullin on 5.05.25.
//

enum RegisterViewIntent {
    case onDidLoad
    case onLoginTapped
    case onRegisterTapped(phone: String, name: String, password: String)
}
