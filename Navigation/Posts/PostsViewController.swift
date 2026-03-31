//
//  PostsViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import UIKit
import StorageService

final class PostsViewController: UIViewController {


        private let tableView = UITableView()
        private let posts = PostProvider.makePosts()
        private let favorites = FavoritesRepository.shared


    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("menu.posts")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension PostsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        cell.configure(post: post, isFavorite: favorites.isFavorite(id: post.id))

        cell.onLikeTap = { [weak self] in
            guard let self else { return }
            _ = self.favorites.toggle(post: post)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PostsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
