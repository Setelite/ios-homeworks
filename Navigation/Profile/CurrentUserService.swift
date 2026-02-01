//
//  CurrentUserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import Foundation
import StorageService
import UIKit

final class CurrentUserService: UserService {

    private let currentUser = User(
        login: "Wowgorno",
        fullName: "Maxim Gornostayev",
        avatar: UIImage(named: "my_photo")!,
        status: "iOS Developer"
    )

    func getUser(login: String) -> User? {
        return login == currentUser.login ? currentUser : nil
    }
}
