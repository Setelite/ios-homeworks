//
//  ProfileViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import UIKit
import StorageService

final class ProfileViewController: UIViewController {
    enum ScreenMode {
        case profile
        case myProfile

        var title: String {
            switch self {
            case .profile:
                return L10n.tr("profile.title")
            case .myProfile:
                return L10n.tr("profile.my_title")
            }
        }
    }

    // MARK: - Properties
    private let viewModel: ProfileViewModel
    private let screenMode: ScreenMode
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let favoritesRepository = FavoritesRepository.shared
    private let headerView = ProfileHeaderView()

    enum Section: Int, CaseIterable {
        case photos
        case music
        case posts
    }

    // MARK: - Init
    init(
        viewModel: ProfileViewModel,
        screenMode: ScreenMode = .profile
    ) {
        self.viewModel = viewModel
        self.screenMode = screenMode
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
        title = screenMode.title
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        navigationItem.largeTitleDisplayMode = .never
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
        tableView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        tableView.separatorStyle = .none
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MusicEntryCell")

        tableView.tableHeaderView = makeHeaderView()
    }

    private func makeHeaderView() -> UIView {
        if let user = viewModel.user {
            headerView.configure(
                with: user,
                friendsCount: viewModel.friendsCount,
                followersCount: viewModel.followersCount
            )
        }
        headerView.onProfileSettingsTap = { [weak self] in
            self?.openProfileSettings()
        }
        headerView.onEditProfileTap = { [weak self] in
            self?.openProfileEditor()
        }
        headerView.onAvatarTap = { [weak self] in
            self?.openAvatarPicker()
        }

        // важный момент: tableHeaderView НЕ считает autoLayout
        let width = view.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 310)

        return headerView
    }

    private func openProfileSettings() {
        let vc = SettingsViewController()
        vc.onChangePassword = { [weak self] in
            guard let self else { return }
            let passwordVC = PasswordViewController()
            passwordVC.onSuccess = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(passwordVC, animated: true)
        }
        vc.onLogout = { [weak self] in
            FirebaseSessionStorage.shared.clear()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openProfileEditor() {
        guard let currentUser = viewModel.user else { return }

        let alert = UIAlertController(
            title: L10n.tr("profile.edit.title"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = L10n.tr("profile.edit.name")
            textField.text = currentUser.fullName
        }
        alert.addTextField { textField in
            textField.placeholder = L10n.tr("profile.edit.status")
            textField.text = currentUser.status
        }

        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.tr("common.save"), style: .default) { [weak self] _ in
            guard
                let self,
                let fullName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let status = alert.textFields?.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !fullName.isEmpty,
                !status.isEmpty
            else { return }

            self.viewModel.updateProfile(fullName: fullName, status: status)
            if let user = self.viewModel.user {
                self.headerView.configure(
                    with: user,
                    friendsCount: self.viewModel.friendsCount,
                    followersCount: self.viewModel.followersCount
                )
            }
        })

        present(alert, animated: true)
    }
    
    private func openAvatarPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
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
        case .music:
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

        case .music:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MusicEntryCell",
                for: indexPath
            )
            var config = cell.defaultContentConfiguration()
            config.text = L10n.tr("music.profile.entry")
            config.secondaryText = L10n.tr("music.profile.subtitle")
            config.image = UIImage(systemName: "music.note.list")
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
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
        case .music:
            return 72
        case .posts:
            let post = viewModel.posts[indexPath.row]
            let contentWidth = tableView.bounds.width - 32
            let descriptionHeight = post.description.boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: StyleGuide.Fonts.caption(14, weight: .regular)],
                context: nil
            ).height

            // author + image(square) + paddings + description + metrics row
            return 16 + 24 + 12 + tableView.bounds.width + 16 + ceil(descriptionHeight) + 20 + 22 + 16
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

        case .music:
            let vc = MyMusicViewController()
            navigationController?.pushViewController(vc, animated: true)

        case .posts:
            let post = viewModel.posts[indexPath.row]
            let vc = PostViewController(post: post)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        let normalized = image.squareCropped()

        viewModel.updateAvatar(normalized)

        if let user = viewModel.user {
            headerView.configure(
                with: user,
                friendsCount: viewModel.friendsCount,
                followersCount: viewModel.followersCount
            )
        }
    }
}

private extension UIImage {
    func squareCropped() -> UIImage {
        let side = min(size.width, size.height)
        let x = (size.width - side) / 2
        let y = (size.height - side) / 2
        let rect = CGRect(x: x, y: y, width: side, height: side)
        guard let cg = cgImage?.cropping(to: rect) else { return self }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }
}
