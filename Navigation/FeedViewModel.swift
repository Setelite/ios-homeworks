//
//  FeedViewModel.swift
//  Navigation
//
//  Created by Codex on 19.02.2026.
//

import Foundation

protocol FeedModelProtocol {
    func check(word: String) -> Bool
}

extension FeedModel: FeedModelProtocol {}

final class FeedViewModel {

    enum State: Equatable {
        case idle
        case emptyInput
        case checked(isCorrect: Bool)
    }

    private let model: FeedModelProtocol
    private(set) var state: State = .idle

    init(model: FeedModelProtocol = FeedModel()) {
        self.model = model
    }

    func check(word: String?) {
        let trimmed = word?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else {
            state = .emptyInput
            return
        }

        let isCorrect = model.check(word: trimmed)
        state = .checked(isCorrect: isCorrect)
    }
}
