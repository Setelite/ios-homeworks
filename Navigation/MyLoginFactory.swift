//
//  MyLoginFactory.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import Foundation

struct MyLoginFactory: LoginFactory {
    func makeLoginInspector() -> LoginInspector {
        return LoginInspector()
    }
}
