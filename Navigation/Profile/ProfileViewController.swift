//
//  ProfileViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import UIKit


final class ProfileViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)

    private let posts: [Post] = [
        Post(author: "Wowgorno", description: "На работе тоже есть чем заняться!", image: "my_photo", likes: 120, views: 300),
        Post(author: "Dady_hulk", description: "Банка", image: "hulk", likes: 95, views: 180),
        Post(author: "Wowgorno", description: "Philipp Plein подарил)))!", image: "pp", likes: 450, views: 900),
        Post(author: "Wowgorno", description: "Как обычно там , где нет никого)))", image: "skala", likes: 270, views: 500)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        view.backgroundColor = .systemGray6

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")

        // Шапка
        let headerView = ProfileHeaderView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
        tableView.tableHeaderView = headerView

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    // Отступ между хедером и первым постом
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}




