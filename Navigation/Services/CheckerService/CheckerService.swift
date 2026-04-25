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
    private let userProfileService: FirebaseUserProfileServiceProtocol
    private let sessionStorage: FirebaseSessionStorage

    init(
        authService: FirebaseAuthServiceProtocol = FirebaseAuthRESTService(),
        userProfileService: FirebaseUserProfileServiceProtocol = FirebaseUserProfileService(),
        sessionStorage: FirebaseSessionStorage = .shared
    ) {
        self.authService = authService
        self.userProfileService = userProfileService
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
                try? await userProfileService.upsertUserProfile(user: session.user, idToken: session.idToken)
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
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
                try await userProfileService.upsertUserProfile(user: session.user, idToken: session.idToken)
                sessionStorage.store(session: session)
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
