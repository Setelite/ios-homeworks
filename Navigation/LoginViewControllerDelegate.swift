//
//  LoginViewControllerDelegate.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import Foundation

protocol LoginViewControllerDelegate: AnyObject {
    func checkCredentials(email: String, password: String)
    func signUp(email: String, password: String)
}
