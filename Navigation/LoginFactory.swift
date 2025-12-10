//
//  LoginFactory.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import Foundation

protocol LoginFactory {
    func makeLoginInspector() -> LoginInspector
}
