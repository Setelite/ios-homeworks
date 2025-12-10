//
//  ProfileViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import UIKit
import StorageService

final class ProfileViewController: UIViewController {
    
    // MARK: - Coordinator callbacks
    var onOpenPhotos: (([String]) -> Void)?

    // MARK: - MVVM
    private let viewModel: ProfileViewModel

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .grouped)

    // MARK: - Init
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()

        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        title = "Profile"
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

        tableView.register(PhotosTableViewCell.self,
                           forCellReuseIdentifier: PhotosTableViewCell.identifier)
        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)
    }
}

// MARK: - DataSource
extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.posts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotosTableViewCell.identifier,
                for: indexPath
            ) as! PhotosTableViewCell

            cell.configure(with: viewModel.photos)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostTableViewCell.identifier,
                for: indexPath
            ) as! PostTableViewCell

            cell.configure(with: viewModel.posts[indexPath.row])
            return cell
        }
    }
}

// MARK: - Delegate
extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            let header = ProfileHeaderView()
            if let user = viewModel.user {
                header.configure(with: user)
            }
            return header
        }

        return nil
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 240 : 0
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        guard indexPath.section == 0 else { return }

        // Навигация через координатор
        onOpenPhotos?(viewModel.photos)
    }
}
