//
//  MyLoginFactory.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import Foundation

struct MyLoginFactory: LoginFactory {

    private let checkerService: CheckerServiceProtocol

    init(checkerService: CheckerServiceProtocol) {
        self.checkerService = checkerService
    }

    func makeLoginInspector() -> LoginInspector {
        LoginInspector(checkerService: checkerService)
    }
}
