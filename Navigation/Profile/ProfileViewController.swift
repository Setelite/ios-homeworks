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
    private let favoritesRepository = FavoritesRepository.shared

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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 700

        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.identifier
        )
        tableView.register(
            PhotosTableViewCell.self,
            forCellReuseIdentifier: PhotosTableViewCell.identifier
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotosTableViewCell.identifier,
                for: indexPath
            ) as! PhotosTableViewCell
            cell.configure(with: viewModel.photos)
            cell.selectionStyle = .none
            return cell

        case .posts:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostTableViewCell.identifier,
                for: indexPath
            ) as! PostTableViewCell

            let post = viewModel.posts[indexPath.row]
            cell.configure(with: post, isFavorite: favoritesRepository.isFavorite(id: post.id))
            cell.onLikeTap = { [weak self, weak tableView] in
                guard let self, let tableView else { return }
                _ = self.favoritesRepository.toggle(post: post)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }

        switch section {
        case .photos:
            return 150
        case .posts:
            let post = viewModel.posts[indexPath.row]
            let contentWidth = tableView.bounds.width - 32
            let descriptionHeight = post.description.boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)],
                context: nil
            ).height

            // author + image(square) + paddings + description + likes/views block
            return 16 + 24 + 12 + tableView.bounds.width + 16 + ceil(descriptionHeight) + 24 + 22 + 8 + 20 + 16
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {

        case .photos:
            let vc = PhotosViewController()
            vc.photos = viewModel.photos
            navigationController?.pushViewController(vc, animated: true)

        case .posts:
            let post = viewModel.posts[indexPath.row]
            let vc = PostViewController(post: post)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
