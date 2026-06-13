//
//  FavoritesViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    var onOpenFiles: (() -> Void)?
    var onOpenSettings: (() -> Void)?

    private let tableView = UITableView()
    private var posts: [Post] = []

    private let favoritesRepository = FavoritesRepository.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.tr("favorites.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupTableView()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAll()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupNavigationBar() {
        let filesButton = UIBarButtonItem(
            image: UIImage(systemName: "folder"),
            style: .plain,
            target: self,
            action: #selector(openFiles)
        )

        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchByAuthor)
        )

        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle"),
            style: .plain,
            target: self,
            action: #selector(clearFilter)
        )

        navigationItem.leftBarButtonItems = [settingsButton, filesButton]
        navigationItem.rightBarButtonItems = [clearButton, searchButton]
    }

    // MARK: - Data

    private func loadAll() {
        posts = favoritesRepository.fetchAll()
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func searchByAuthor() {
        let alert = UIAlertController(
            title: L10n.tr("favorites.search.title"),
            message: L10n.tr("favorites.search.message"),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = L10n.tr("favorites.search.placeholder")
        }

        let apply = UIAlertAction(title: L10n.tr("common.apply"), style: .default) { _ in
            let author = alert.textFields?.first?.text ?? ""

            if author.isEmpty {
                self.loadAll()
            } else {
                self.posts = self.favoritesRepository
                    .fetchAll()
                    .filter { $0.author.lowercased().contains(author.lowercased()) }

                self.tableView.reloadData()
            }
        }

        let cancel = UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel)

        alert.addAction(apply)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @objc private func clearFilter() {
        loadAll()
    }

    @objc private func openFiles() {
        onOpenFiles?()
    }

    @objc private func openSettings() {
        onOpenSettings?()
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        posts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostCell",
            for: indexPath
        ) as! PostCell

        let post = posts[indexPath.row]

        cell.configure(post: post, isFavorite: true)

        cell.onLikeTap = { [weak self] in
            guard let self else { return }

            _ = self.favoritesRepository.toggle(post: post)
            self.loadAll()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(
            style: .destructive,
            title: L10n.tr("common.delete")
        ) { [weak self] _, _, completion in
            guard let self else { return }

            let post = self.posts[indexPath.row]
            _ = self.favoritesRepository.toggle(post: post)

            self.posts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
}
