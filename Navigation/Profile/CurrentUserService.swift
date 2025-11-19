//
//  CurrentUserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import UIKit

final class CurrentUserService: UserService {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func getUser(login: String) -> User? {
        // Проверка логина
        return login == user.login ? user : nil
    }
}
