//
//  TestUserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import UIKit

final class TestUserService: UserService {
    private let testUser = User(login: "wowgorno",
                                fullName: "Test User",
                                avatar: UIImage(named: "avatar") ?? UIImage(),
                                status: "DEBUG MODE")

    func getUser(login: String) -> User? {
        return login == testUser.login ? testUser : nil
    }
}
