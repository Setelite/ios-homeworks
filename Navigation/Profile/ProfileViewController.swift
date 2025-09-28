//
//  ProfileViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import StorageService
import UIKit

final class ProfileViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let posts: [Post] = [
        Post(author: "Wowgorno", description: "На работе тоже есть чем заняться!", image: "my_photo", likes: 120, views: 300),
        Post(author: "Dady_hulk", description: "Банка", image: "hulk", likes: 95, views: 180),
        Post(author: "Wowgorno", description: "Philipp Plein подарил)))!", image: "pp", likes: 450, views: 900),
        Post(author: "Wowgorno", description: "Как обычно там , где нет никого)))", image: "skala", likes: 270, views: 500)
    ]
    
    private let photos = ["my_photo", "hulk", "pp", "skala"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
#if DEBUG
tableView.backgroundColor = .systemGreen
#else
tableView.backgroundColor = .systemBlue
#endif

        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: PhotosTableViewCell.identifier)
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // секция 0 = фото, секция 1 = посты
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotosTableViewCell.identifier, for: indexPath) as! PhotosTableViewCell
            cell.configure(with: photos)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            cell.configure(with: posts[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return ProfileHeaderView()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 220 : 0
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let photosVC = PhotosViewController()
            photosVC.photos = photos
            navigationController?.pushViewController(photosVC, animated: true)
        }
    }
    
}
