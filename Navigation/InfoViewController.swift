//
//  InfoViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

final class InfoViewController: UIViewController {

    private let filmTitleLabel = UILabel()
    private let planetPeriodLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("INFO VC LOADED")

        view.backgroundColor = StyleGuide.Colors.backgroundSecondary

        setupLabels()
        setupButton()

        fetchFilm()
        fetchPlanet()
    }

    // MARK: - UI

    private func setupLabels() {
        filmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        planetPeriodLabel.translatesAutoresizingMaskIntoConstraints = false

        filmTitleLabel.font = StyleGuide.Fonts.title(20)
        filmTitleLabel.textColor = StyleGuide.Colors.textPrimary
        filmTitleLabel.textAlignment = .center
        filmTitleLabel.numberOfLines = 0
        filmTitleLabel.text = L10n.tr("info.loading_film")

        planetPeriodLabel.font = StyleGuide.Fonts.body(16, weight: .medium)
        planetPeriodLabel.textColor = StyleGuide.Colors.textSecondary
        planetPeriodLabel.textAlignment = .center
        planetPeriodLabel.numberOfLines = 0
        planetPeriodLabel.text = L10n.tr("info.loading_planet")

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
        button.setTitle(L10n.tr("info.show_alert"), for: .normal)
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
                    self.planetPeriodLabel.text = L10n.format("info.tatooine_period", planet.orbitalPeriod)
                }
            } catch {
                print("Planet decoding error:", error.localizedDescription)
            }
        }.resume()
    }

    // MARK: - Alert

    @objc private func showAlert() {
        let alert = UIAlertController(
            title: L10n.tr("info.alert.title"),
            message: L10n.tr("info.alert.message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.tr("common.ok"), style: .default))
        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))

        present(alert, animated: true)
    }
}
