//
//  FeedModel.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/26/25.
//

final class FeedModel {
    private let secretWord = "apple"

    func check(word: String) -> Bool {
        return word.lowercased() == secretWord.lowercased()
    }
}
