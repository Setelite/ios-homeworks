//
//  NetworkService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12/16/25.
//

import Foundation

protocol NetworkSessionProtocol {
    func dataTask(with url: URL,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

final class URLSessionNetworkSession: NetworkSessionProtocol {
    func dataTask(with url: URL,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: completion)
        task.resume()
    }
}

enum NetworkServiceResult: Equatable {
    case success(data: String, statusCode: Int?)
    case failure(String)
    case empty
    case invalidURL
}

struct NetworkService {

    static func request(for configuration: AppConfiguration,
                        session: NetworkSessionProtocol = URLSessionNetworkSession(),
                        completion: ((NetworkServiceResult) -> Void)? = nil) {

        let url: URL

        switch configuration {
        case .people(let urlString),
             .starship(let urlString),
             .planet(let urlString):

            guard let validURL = URL(string: urlString) else {
                completion?(.invalidURL)
                print("Некорректный URL")
                return
            }
            url = validURL
        }

        session.dataTask(with: url) { data, response, error in

            if let error = error {
                let result: NetworkServiceResult = .failure(error.localizedDescription)
                completion?(result)
                print("Error:", error.localizedDescription)
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode

            if let data = data,
               !data.isEmpty,
               let dataString = String(data: data, encoding: .utf8) {
                let result: NetworkServiceResult = .success(data: dataString, statusCode: statusCode)
                completion?(result)
                print("Status code:", statusCode ?? -1)
                print("Data:\n", dataString)
            } else {
                let result: NetworkServiceResult = .empty
                completion?(result)
            }
        }
    }
}
