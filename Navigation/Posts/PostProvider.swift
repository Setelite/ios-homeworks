//
//  PostProvider.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import Foundation

final class PostProvider {

    static func makePosts() -> [Post] {
        [
            Post(
                author: "Wowgorno",
                description: "Первый пост",
                image: "post1",
                likes: 120,
                views: 340
            ),
            Post(
                author: "Maria",
                description: "Второй пост",
                image: "post2",
                likes: 89,
                views: 210
            ),
            Post(
                author: "John",
                description: "Третий пост",
                image: "post3",
                likes: 450,
                views: 980
            )
        ]
    }
}
