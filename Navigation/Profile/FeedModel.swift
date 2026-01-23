//
//  FeedModel.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/26/25.
//
import Foundation

final class FeedModel {

    let posts: [Post] = PostProvider.makePosts()
    
    // A simple correct word for demonstration
    private let correctWord = "кот" // Russian for "cat", adjust as needed

    func check(word: String) -> Bool {
        word.trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedCaseInsensitiveCompare(correctWord) == .orderedSame
    }
}
