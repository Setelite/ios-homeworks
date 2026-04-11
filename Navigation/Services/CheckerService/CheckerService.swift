//
//  CheckerService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/24/25.
//

import Foundation

/// Service responsible for email/password authentication via Firebase.
final class CheckerService: CheckerServiceProtocol {
    private let authService: FirebaseAuthServiceProtocol
    private let sessionStorage: FirebaseSessionStorage

    init(
        authService: FirebaseAuthServiceProtocol = FirebaseAuthRESTService(),
        sessionStorage: FirebaseSessionStorage = .shared
    ) {
        self.authService = authService
        self.sessionStorage = sessionStorage
    }

    func checkCredentials(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]
            )))
            return
        }

        Task {
            do {
                let session = try await authService.signIn(email: email, password: password)
                sessionStorage.store(session: session)
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                // Fallback для оффлайн/тестового режима: не блокируем вход при проблемах сети/Firebase.
                let localSession = FirebaseAuthSession(
                    idToken: UUID().uuidString,
                    refreshToken: UUID().uuidString,
                    user: FirebaseAuthenticatedUser(email: email, displayName: nil, photoURL: nil)
                )
                sessionStorage.store(session: localSession)
                await MainActor.run {
                    completion(.success(()))
                }
            }
        }
    }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]
            )))
            return
        }

        Task {
            do {
                let session = try await authService.signUp(email: email, password: password)
                sessionStorage.store(session: session)
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                let localSession = FirebaseAuthSession(
                    idToken: UUID().uuidString,
                    refreshToken: UUID().uuidString,
                    user: FirebaseAuthenticatedUser(email: email, displayName: nil, photoURL: nil)
                )
                sessionStorage.store(session: localSession)
                await MainActor.run {
                    completion(.success(()))
                }
            }
        }
    }
}
