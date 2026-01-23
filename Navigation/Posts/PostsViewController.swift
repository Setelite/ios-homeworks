//
//  PostsViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import UIKit

final class PostsViewController: UIViewController {

    private let tableView = UITableView()
    private let posts = PostProvider.makePosts()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground

        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
    }
}

extension PostsViewController: UITableViewDataSource {

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
        cell.configure(with: post)

        cell.onDoubleTap = {
            FavoritesRepository.shared.save(post: post)
        }

        return cell
    }
}
