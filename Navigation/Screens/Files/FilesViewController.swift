//
//  FilesViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import UIKit

final class FilesViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView()

    // MARK: - Data
    private var files: [String] = [
        "Document.txt",
        "Image.png",
        "Notes.md",
        "Archive.zip",
        "Presentation.key",
        "Report.pdf"
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Файлы"
        view.backgroundColor = .systemBackground

        setupTableView()
        sortFiles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortFiles()
        tableView.reloadData()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FileCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Sorting
    private func sortFiles() {
        let isAscending = UserDefaults.standard.bool(forKey: "sortAscending")

        files.sort {
            isAscending ? $0.localizedCompare($1) == .orderedAscending
                        : $0.localizedCompare($1) == .orderedDescending
        }
    }
}

// MARK: - UITableViewDataSource
extension FilesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FileCell",
            for: indexPath
        )

        cell.textLabel?.text = files[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
