//
//  CheckerService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/24/25.
//

import Foundation

final class CheckerService: CheckerServiceProtocol {

    func checkCredentials(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        if !email.isEmpty && !password.isEmpty {
            completion(.success(()))
        } else {
            completion(.failure(NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]
            )))
        }
    }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(.success(()))
    }
}

