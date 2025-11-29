//
//  ProfileViewModel.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit
import StorageService

final class ProfileViewModel {

    // MARK: - Inputs
    private let userService: UserService
    private let login: String

    // MARK: - Outputs (данные для View)
    private(set) var user: User?
    private(set) var posts: [Post] = []
    private(set) var photos: [String] = []

    // MARK: - Binding callback
    var onDataChanged: (() -> Void)?

    // MARK: - Init
    init(login: String, userService: UserService = TestUserService()) {
        self.login = login
        self.userService = userService
        loadData()
    }

    // MARK: - Methods
    private func loadData() {
        self.user = userService.getUser(login: login)

        self.posts = [
            Post(author: "Wowgorno", description: "На работе тоже есть чем заняться!", image: "my_photo", likes: 120, views: 300),
            Post(author: "Dady_hulk", description: "Банка", image: "hulk", likes: 95, views: 180),
            Post(author: "Wowgorno", description: "Philipp Plein подарил)))!", image: "pp", likes: 450, views: 900),
            Post(author: "Wowgorno", description: "Как обычно там , где нет никого)))", image: "skala", likes: 270, views: 500)
        ]

        self.photos = ["my_photo", "hulk", "pp", "skala"]

        onDataChanged?()    // уведомляем контроллер
    }
}
