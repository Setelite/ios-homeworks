//
//  LoginFactory.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
import Foundation

/// Фабрика создания объектов проверки (делегата)
protocol LoginFactory {
    func makeLoginInspector() -> LoginInspector
}

/// Реализация фабрики
final class DefaultLoginFactory: LoginFactory {
    func makeLoginInspector() -> LoginInspector {
        let inspector: LoginInspector = LoginInspector()
        return inspector
    }
}
