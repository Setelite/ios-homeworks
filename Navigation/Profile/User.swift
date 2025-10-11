//
//  User.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import UIKit

// MARK: - Модель пользователя
final class User {
    let login: String
    let fullName: String
    let avatar: UIImage
    let status: String
    
    init(login: String, fullName: String, avatar: UIImage, status: String) {
        self.login = login
        self.fullName = fullName
        self.avatar = avatar
        self.status = status
    }
}

// MARK: - Протокол UserService
protocol AppUserService {
    func getUser(by login: String) -> User?
}


