//
//  ProfileViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import UIKit
import StorageService

final class ProfileViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: ProfileViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)

    enum Section: Int, CaseIterable {
        case photos
        case posts
    }

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
        setupUI()
        setupTableView()
    }

    // MARK: - UI
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
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

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.identifier
        )

        tableView.tableHeaderView = makeHeaderView()
    }

    private func makeHeaderView() -> UIView {
        let headerView = ProfileHeaderView()

        if let user = viewModel.user {
            headerView.configure(with: user)
        }

        // важный момент: tableHeaderView НЕ считает autoLayout
        let width = view.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 240)

        return headerView
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .photos:
            return 1
        case .posts:
            return viewModel.posts.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {

        case .photos:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "PhotosCell")
            cell.textLabel?.text = "Фотографии"
            cell.accessoryType = .disclosureIndicator
            return cell

        case .posts:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostTableViewCell.identifier,
                for: indexPath
            ) as! PostTableViewCell

            cell.configure(with: viewModel.posts[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {

        case .photos:
            let vc = PhotosViewController()
            navigationController?.pushViewController(vc, animated: true)

        case .posts:
            let post = viewModel.posts[indexPath.row]
            let vc = PostViewController(post: post)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
