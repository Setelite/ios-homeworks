//
//  UserService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/11/25.
//

import Foundation
protocol UserService {
    func getUser(login: String) -> User?
}
