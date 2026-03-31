//
//  ProfileViewModel.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit
import StorageService

final class ProfileViewModel {

    private(set) var user: User?
    var posts: [Post]
    var photos: [String]
    let friendsCount: Int
    let followersCount: Int

    var onDataChanged: (() -> Void)?

    init(user: User?) {
        self.user = user
        self.friendsCount = 248
        self.followersCount = 1302

        self.posts = [
            Post(author: "Wowgorno", description: L10n.tr("profile.post.1"), image: "my_photo", likes: 120, views: 300),
            Post(author: "Dady_hulk", description: L10n.tr("profile.post.2"), image: "hulk", likes: 95, views: 180),
            Post(author: "Wowgorno", description: L10n.tr("profile.post.3"), image: "pp", likes: 450, views: 900),
            Post(author: "Wowgorno", description: L10n.tr("profile.post.4"), image: "skala", likes: 270, views: 500)
        ]

        self.photos = ["my_photo", "hulk", "pp", "skala"]
    }

    func updateProfile(fullName: String, status: String) {
        guard let user else { return }
        self.user = User(
            login: user.login,
            fullName: fullName,
            avatar: user.avatar,
            status: status
        )
        onDataChanged?()
    }
    
    func updateAvatar(_ image: UIImage) {
        guard let user else { return }
        self.user = User(
            login: user.login,
            fullName: user.fullName,
            avatar: image,
            status: user.status
        )
        onDataChanged?()
    }
}
