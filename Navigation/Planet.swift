//
//  P;anet.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/18/25.
//

struct Planet: Decodable {
    let orbitalPeriod: String

    enum CodingKeys: String, CodingKey {
        case orbitalPeriod = "orbital_period"
    }
}
