//
//  ProfileViewModel.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit
import StorageService

final class ProfileViewModel {

    let user: User?
    var posts: [Post]
    var photos: [String]

    var onDataChanged: (() -> Void)?

    init(user: User?) {
        self.user = user

        self.posts = [
            Post(author: "Wowgorno", description: "На работе тоже есть чем заняться!", image: "my_photo", likes: 120, views: 300),
            Post(author: "Dady_hulk", description: "Банка", image: "hulk", likes: 95, views: 180),
            Post(author: "Wowgorno", description: "Philipp Plein подарил)))!", image: "pp", likes: 450, views: 900),
            Post(author: "Wowgorno", description: "Как обычно там , где нет никого)))", image: "skala", likes: 270, views: 500)
        ]

        self.photos = ["my_photo", "hulk", "pp", "skala"]
    }
}

