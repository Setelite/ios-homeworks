//
//  PostProvider.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import Foundation

enum PostProvider {

    static func makePosts() -> [Post] {
        [
            Post(
                author: L10n.tr("post.author.vk_media"),
                description: L10n.tr("post.sample.first"),
                image: "my_photo",
                likes: 10,
                views: 120
            ),
            Post(
                author: L10n.tr("post.author.friends"),
                description: L10n.tr("post.sample.second"),
                image: "hulk",
                likes: 25,
                views: 300
            ),
            Post(
                author: L10n.tr("post.author.design"),
                description: L10n.tr("post.sample.third"),
                image: "pp",
                likes: 42,
                views: 512
            )
        ]
    }
}
