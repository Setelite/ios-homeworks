//
//  PasswordState.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/14/26.
//

enum PasswordState {
    case create
    case repeatPassword(first: String)
    case enter(saved: String)
}
