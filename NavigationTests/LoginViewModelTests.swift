//
//  LoginViewModelTests.swift
//  NavigationTests
//
//  Created by Codex on 19.02.2026.
//

import XCTest
@testable import Navigation

final class LoginViewModelTests: XCTestCase {

    func testSubmit_withEmptyEmail_setsErrorState() {
        let viewModel = LoginViewModel()

        viewModel.submit(email: " ", password: "pass")

        XCTAssertEqual(viewModel.state, .errorEmpty)
    }

    func testSubmit_withEmptyPassword_setsErrorState() {
        let viewModel = LoginViewModel()

        viewModel.submit(email: "user@example.com", password: "")

        XCTAssertEqual(viewModel.state, .errorEmpty)
    }

    func testSubmit_withValidCredentials_trimsAndSetsReadyState() {
        let viewModel = LoginViewModel()

        viewModel.submit(email: "  user@example.com  ", password: "  secret  ")

        XCTAssertEqual(viewModel.state, .ready(email: "user@example.com", password: "secret"))
    }
}
