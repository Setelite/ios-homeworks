//
//  FavoritesViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

final class FavoritesViewController: UITableViewController {

    private let repository = FavoritesRepository.shared
    private var posts: [Post] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts = repository.fetchAll()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}
