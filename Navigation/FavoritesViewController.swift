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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        view.backgroundColor = .systemBackground

        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts = favoritesRepository.fetchAll()
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostCell",
            for: indexPath
        ) as! PostCell

        let post = posts[indexPath.row]

        cell.configure(post: post, isFavorite: true)

        cell.onLikeTap = { [weak self] in
            guard let self else { return }

            _ = self.favoritesRepository.toggle(post: post)
            self.posts = self.favoritesRepository.fetchAll()
            tableView.reloadData()
        }

        // ❗️ВОТ ЭТОГО return И НЕ ХВАТАЛО
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
