//
//  Post.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12.08.2025.
//

import Foundation

struct Post {
    let id: String
    let author: String
    let description: String
    let image: String
    let likes: Int
    let views: Int

    // Add an initializer for easy migration
    init(id: String = UUID().uuidString,
         author: String,
         description: String,
         image: String,
         likes: Int,
         views: Int) {
        self.id = id
        self.author = author
        self.description = description
        self.image = image
        self.likes = likes
        self.views = views
    }
}
