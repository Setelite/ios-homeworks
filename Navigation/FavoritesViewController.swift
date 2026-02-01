//
//  FavoritesViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let tableView = UITableView()
    private var posts: [Post] = []

    private let favoritesRepository = FavoritesRepository.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        view.backgroundColor = .systemBackground

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
            title: "Поиск по автору",
            message: "Введите имя автора",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Автор"
        }

        let apply = UIAlertAction(title: "Применить", style: .default) { _ in
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

        let cancel = UIAlertAction(title: "Отмена", style: .cancel)

        alert.addAction(apply)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @objc private func clearFilter() {
        loadAll()
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
            title: "Удалить"
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
