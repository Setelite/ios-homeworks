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
                author: "Нетология",
                description: "Первый пост",
                image: "post1",
                likes: 10,
                views: 120
            ),
            Post(
                author: "iOS Dev",
                description: "Второй пост",
                image: "post2",
                likes: 25,
                views: 300
            ),
            Post(
                author: "Swift",
                description: "Третий пост",
                image: "post3",
                likes: 42,
                views: 512
            )
        ]
    }
}
