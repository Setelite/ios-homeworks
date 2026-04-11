//
//  FeedViewModel.swift
//  Navigation
//
//  Created by Codex on 19.02.2026.
//

import Foundation

protocol WordValidationServiceProtocol {
    func check(word: String) -> Bool
}

struct WordValidationService: WordValidationServiceProtocol {
    // Демонстрационное слово для экрана проверки.
    private let correctWord = "кот"

    func check(word: String) -> Bool {
        word.trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedCaseInsensitiveCompare(correctWord) == .orderedSame
    }
}

final class FeedViewModel {

    enum State: Equatable {
        case idle
        case emptyInput
        case checked(isCorrect: Bool)
    }

    private let model: WordValidationServiceProtocol
    private(set) var state: State = .idle

    init(model: WordValidationServiceProtocol = WordValidationService()) {
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
