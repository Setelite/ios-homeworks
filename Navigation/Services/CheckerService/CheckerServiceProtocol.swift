//
//  CheckerServiceProtocol.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/24/25.
//

protocol CheckerServiceProtocol {
    func checkCredentials(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
