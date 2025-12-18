//
//  InfoViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

class InfoViewController: UIViewController {

    private let filmTitleLabel = UILabel()
    private let planetPeriodLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("INFO VC LOADED")

        view.backgroundColor = .systemGray6

        setupLabels()
        setupButton()

        fetchFilm()
        fetchPlanet()
    }

    // MARK: - UI

    private func setupLabels() {
        filmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        planetPeriodLabel.translatesAutoresizingMaskIntoConstraints = false

        filmTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        filmTitleLabel.textAlignment = .center
        filmTitleLabel.numberOfLines = 0
        filmTitleLabel.text = "Loading film..."

        planetPeriodLabel.font = .systemFont(ofSize: 16, weight: .medium)
        planetPeriodLabel.textAlignment = .center
        planetPeriodLabel.numberOfLines = 0
        planetPeriodLabel.text = "Loading planet..."

        view.addSubview(filmTitleLabel)
        view.addSubview(planetPeriodLabel)

        NSLayoutConstraint.activate([
            filmTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filmTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            filmTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filmTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            planetPeriodLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetPeriodLabel.topAnchor.constraint(equalTo: filmTitleLabel.bottomAnchor, constant: 20),
            planetPeriodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            planetPeriodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("Show Alert", for: .normal)
        button.addTarget(self, action: #selector(showAlert), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: planetPeriodLabel.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Network (Task 1)

    private func fetchFilm() {
        let urlString = "https://swapi.dev/api/films/1"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Film error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let title = json?["title"] as? String

                DispatchQueue.main.async {
                    self.filmTitleLabel.text = title
                }
            } catch {
                print("Film parsing error:", error.localizedDescription)
            }
        }.resume()
    }

    // MARK: - Network (Task 2)

    private func fetchPlanet() {
        let urlString = "https://swapi.dev/api/planets/1" // Татуин
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Planet error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let planet = try JSONDecoder().decode(Planet.self, from: data)

                DispatchQueue.main.async {
                    self.planetPeriodLabel.text =
                    "Orbital period of Tatooine: \(planet.orbitalPeriod)"
                }
            } catch {
                print("Planet decoding error:", error.localizedDescription)
            }
        }.resume()
    }

    // MARK: - Alert

    @objc private func showAlert() {
        let alert = UIAlertController(
            title: "Info",
            message: "This is an alert",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
