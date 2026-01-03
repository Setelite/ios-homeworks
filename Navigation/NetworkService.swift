//
//  NetworkService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/16/25.
//

import Foundation

struct NetworkService {

    static func request(for configuration: AppConfiguration) {

        let url: URL

        switch configuration {
        case .people(let urlString),
             .starship(let urlString),
             .planet(let urlString):

            guard let validURL = URL(string: urlString) else {
                print("Некорректный URL")
                return
            }
            url = validURL
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Error:", error.localizedDescription)
                
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
                print("Headers:", httpResponse.allHeaderFields)
            }

            if let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                print("Data:\n", dataString)
            }
        }

        task.resume()
    }
}
