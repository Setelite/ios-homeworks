//
//  FeedViewModelTests.swift
//  NavigationTests
//
//  Created by Codex on 19.02.2026.
//

import XCTest
@testable import Navigation

final class FeedViewModelTests: XCTestCase {

    private final class FeedModelMock: FeedModelProtocol {
        var checkResult: Bool = false
        private(set) var lastWord: String?

        func check(word: String) -> Bool {
            lastWord = word
            return checkResult
        }
    }

    func testCheck_withEmptyInput_setsEmptyInputState() {
        let model = FeedModelMock()
        let viewModel = FeedViewModel(model: model)

        viewModel.check(word: "   ")

        XCTAssertEqual(viewModel.state, .emptyInput)
        XCTAssertNil(model.lastWord)
    }

    func testCheck_withCorrectWord_setsCheckedTrueState() {
        let model = FeedModelMock()
        model.checkResult = true
        let viewModel = FeedViewModel(model: model)

        viewModel.check(word: "кот")

        XCTAssertEqual(viewModel.state, .checked(isCorrect: true))
        XCTAssertEqual(model.lastWord, "кот")
    }

    func testCheck_withIncorrectWord_setsCheckedFalseState() {
        let model = FeedModelMock()
        model.checkResult = false
        let viewModel = FeedViewModel(model: model)

        viewModel.check(word: "собака")

        XCTAssertEqual(viewModel.state, .checked(isCorrect: false))
        XCTAssertEqual(model.lastWord, "собака")
    }
}
