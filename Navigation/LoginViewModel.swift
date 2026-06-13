//
//  LoginViewModel.swift
//  Navigation
//
//  Created by Codex on 19.02.2026.
//

import Foundation

final class LoginViewModel {

    enum State: Equatable {
        case idle
        case errorEmpty
        case ready(email: String, password: String)
    }

    private(set) var state: State = .idle

    func submit(email: String?, password: String?) {
        let trimmedEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedPassword = password?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            state = .errorEmpty
            return
        }

        state = .ready(email: trimmedEmail, password: trimmedPassword)
    }
}
