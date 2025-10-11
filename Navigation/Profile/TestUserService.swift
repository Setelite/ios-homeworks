//
//  TestUserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import UIKit

final class TestUserService: UserService {
    
    private let testUser = User(
        login: "testUser",
        fullName: "Debug TestUser",
        avatar: UIImage(systemName: "person.crop.circle.fill")!,
        status: "Отладочная сборка активна!"
    )
    
    func getUser(login: String) -> User? {
        // В Debug всегда возвращаем тестового пользователя
        return login == testUser.login ? testUser : nil
    }
}
