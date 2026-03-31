import UIKit

final class HomeViewController: UIViewController {
    private enum FeatureFlags {
        // CloudKit is disabled for Personal Team builds to avoid runtime crashes without entitlement.
        static let cloudSyncEnabled = false
    }

    /// Сохраненное созданных пользователями публикаций в `UserDefaults`.
    private struct StoredPublication: Codable {
        let id: String
        let author: String
        let description: String
        let imageFileName: String
        let likes: Int
        let views: Int
        let comments: Int
        let shares: Int
        let isLiked: Bool
    }

    private enum StorageKeys {
        static let customPublications = "home.customPublications"
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let favoritesRepository = FavoritesRepository.shared
    private let cloudPostsService: CloudPostsService? = {
        guard FeatureFlags.cloudSyncEnabled else { return nil }
        return CloudPostsService(container: .default())
    }()
    private let stateView = ScreenStateView()
    private var avatarImage: UIImage?
    private var pendingImageForPost: UIImage?
    var onOpenProfile: (() -> Void)?

    private var stories: [StoryItem] = [
        StoryItem(id: UUID().uuidString, name: "Maxim", imageName: "my_photo"),
        StoryItem(id: UUID().uuidString, name: "Dady", imageName: "hulk"),
        StoryItem(id: UUID().uuidString, name: "Plein", imageName: "pp"),
        StoryItem(id: UUID().uuidString, name: "Swift", imageName: "post1"),
        StoryItem(id: UUID().uuidString, name: "Netology", imageName: "post2")
    ]

    // мои публикации в ленте
    private var feed: [HomeFeedPost] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.home")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupNavigationBar()
        setupTableView()
        setupStoriesHeader()
        setupStateView()
        stateView.onRetry = { [weak self] in
            self?.loadRemotePosts()
        }

        loadRemotePosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = CurrentUserService().getUser(login: "Wowgorno")
        configureAvatar(user?.avatar)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 440
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(HomePostCell.self, forCellReuseIdentifier: HomePostCell.identifier)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStoriesHeader() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 116))
        headerContainer.backgroundColor = StyleGuide.Colors.backgroundPrimary

        let storiesView = StoriesHeaderView()
        storiesView.translatesAutoresizingMaskIntoConstraints = false
        storiesView.configure(with: stories)
        storiesView.onStoryTap = { [weak self] _, index in
            self?.openStory(at: index)
        }

        headerContainer.addSubview(storiesView)
        NSLayoutConstraint.activate([
            storiesView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 4),
            storiesView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            storiesView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            storiesView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -4)
        ])

        tableView.tableHeaderView = headerContainer
    }

    private func setupStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateView)
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        applyAvatarImage()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.square.on.square"),
            style: .plain,
            target: self,
            action: #selector(addPostTapped)
        )
    }

    func configureAvatar(_ image: UIImage?) {
        avatarImage = image
        if isViewLoaded {
            applyAvatarImage()
        }
    }

    private func applyAvatarImage() {
        let image = makeAvatarBarImage(from: avatarImage)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = nil
    }

    private func makeAvatarBarImage(from image: UIImage?) -> UIImage {
        let size = CGSize(width: 30, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()

            if let image {
                image.draw(in: rect)
            } else {
                UIColor.systemGray5.setFill()
                path.fill()
                let symbol = UIImage(systemName: "person.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                symbol?.draw(in: CGRect(x: 8, y: 7, width: 14, height: 16))
            }
        }.withRenderingMode(.alwaysOriginal)
    }

    private func loadContent() {
        stateView.apply(.loading(L10n.tr("home.state.loading")))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if self.feed.isEmpty {
                self.stateView.apply(.empty(L10n.tr("home.state.empty")))
            } else {
                self.tableView.reloadData()
                self.stateView.apply(.content)
            }
        }
    }

    private func toggleLike(at index: Int) {
        guard feed.indices.contains(index) else { return }

        feed[index].isLiked.toggle()
        feed[index].likeCount += feed[index].isLiked ? 1 : -1

        if feed[index].isCustomPublication {
            persistCustomPublications()
            syncCustomPostToCloud(feed[index])
        } else {
            if feed[index].isLiked {
                favoritesRepository.save(post: feed[index].post)
            } else {
                favoritesRepository.remove(id: feed[index].post.id)
            }
        }

        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func addComment(at index: Int) {
        guard feed.indices.contains(index) else { return }
        feed[index].commentCount += 1
        if feed[index].isCustomPublication {
            persistCustomPublications()
            syncCustomPostToCloud(feed[index])
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func sharePost(at index: Int) {
        guard feed.indices.contains(index) else { return }
        feed[index].shareCount += 1

        let activity = UIActivityViewController(
            activityItems: [feed[index].post.description],
            applicationActivities: nil
        )
        present(activity, animated: true)

        if feed[index].isCustomPublication {
            persistCustomPublications()
            syncCustomPostToCloud(feed[index])
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func openStory(at index: Int) {
        let viewer = StoryViewerViewController(stories: stories, initialIndex: index)
        present(viewer, animated: true)
    }

    @objc private func addPostTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func profileTapped() {
        if let onOpenProfile {
            onOpenProfile()
            return
        }

        let user = CurrentUserService().getUser(login: "Wowgorno")
        let vm = ProfileViewModel(user: user)
        let profileVC = ProfileViewController(
            viewModel: vm,
            screenMode: .myProfile
        )
        navigationController?.pushViewController(profileVC, animated: true)
    }

    private func presentCreatePostDialog() {
        let alert = UIAlertController(
            title: L10n.tr("home.post.new_title"),
            message: L10n.tr("home.post.new_message"),
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = L10n.tr("home.post.description_placeholder")
        }
        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel) { [weak self] _ in
            self?.pendingImageForPost = nil
        })
        alert.addAction(UIAlertAction(title: L10n.tr("home.post.publish"), style: .default) { [weak self] _ in
            guard let self else { return }
            let description = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.publishNewPost(description: description)
        })
        present(alert, animated: true)
    }

    private func publishNewPost(description: String?) {
        guard let image = pendingImageForPost else { return }
        pendingImageForPost = nil

        let text = (description?.isEmpty == false) ? description! : L10n.tr("home.post.new_title")
        guard let imageFileName = saveImageToDocuments(image) else {
            stateView.apply(.error(L10n.tr("home.error.save_photo")))
            return
        }

        let newPost = Post(
            author: L10n.tr("common.you"),
            description: text,
            image: "post1",
            likes: 0,
            views: 0
        )

        feed.insert(
            HomeFeedPost(
                post: newPost,
                localImage: image,
                localImageFileName: imageFileName,
                likeCount: 0,
                commentCount: 0,
                shareCount: 0,
                isLiked: false,
                isCustomPublication: true
            ),
            at: 0
        )
        enforceCustomPostLimit(maxCount: 3)

        persistCustomPublications()
        syncCustomPostToCloud(feed[0])
        stateView.apply(.content)
        tableView.reloadData()
    }

    private func persistCustomPublications() {
        // сохранения сообщений в ленте автора
        let stored: [StoredPublication] = Array(feed.compactMap { item in
            guard item.isCustomPublication, let fileName = item.localImageFileName else { return nil }
            return StoredPublication(
                id: item.post.id,
                author: item.post.author,
                description: item.post.description,
                imageFileName: fileName,
                likes: item.likeCount,
                views: item.post.views,
                comments: item.commentCount,
                shares: item.shareCount,
                isLiked: item.isLiked
            )
        }.prefix(3))

        guard let data = try? JSONEncoder().encode(stored) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.customPublications)
    }

    private func loadCustomPublications() {
        guard
            let data = UserDefaults.standard.data(forKey: StorageKeys.customPublications),
            let stored = try? JSONDecoder().decode([StoredPublication].self, from: data)
        else { return }

        let loaded: [HomeFeedPost] = stored.compactMap { item in
            guard let image = loadImageFromDocuments(named: item.imageFileName) else { return nil }
            let post = Post(
                id: item.id,
                author: item.author,
                description: item.description,
                image: "post1",
                likes: item.likes,
                views: item.views
            )
            return HomeFeedPost(
                post: post,
                localImage: image,
                localImageFileName: item.imageFileName,
                likeCount: item.likes,
                commentCount: item.comments,
                shareCount: item.shares,
                isLiked: item.isLiked,
                isCustomPublication: true
            )
        }

        feed = Array(loaded.prefix(3))
    }

    private func enforceCustomPostLimit(maxCount: Int) {
        guard maxCount > 0 else { return }

        let customIndexes = feed.enumerated()
            .filter { $0.element.isCustomPublication }
            .map(\.offset)

        guard customIndexes.count > maxCount else { return }

        let toRemove = customIndexes.dropFirst(maxCount).sorted(by: >)
        for index in toRemove {
            if let fileName = feed[index].localImageFileName {
                removeImageFromDocuments(named: fileName)
            }
            removeCustomPostFromCloud(postId: feed[index].post.id)
            feed.remove(at: index)
        }
    }

    private func loadRemotePosts() {
        guard let cloudPostsService else {
            loadCustomPublications()
            loadContent()
            return
        }

        stateView.apply(.loading(L10n.tr("home.state.loading")))

        cloudPostsService.fetchPosts { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    if posts.isEmpty {
                        self.loadCustomPublications()
                        self.uploadCachedPostsToCloudIfNeeded()
                    } else {
                        self.feed = posts.map { self.makeHomeFeedPost(from: $0) }
                    }
                    self.loadContent()

                case .failure:
                    self.loadCustomPublications()
                    self.loadContent()
                }
            }
        }
    }

    private func makeHomeFeedPost(from cloudPost: CloudPost) -> HomeFeedPost {
        let post = Post(
            id: cloudPost.id,
            author: cloudPost.author,
            description: cloudPost.description,
            image: "post1",
            likes: cloudPost.likes,
            views: cloudPost.views
        )

        return HomeFeedPost(
            post: post,
            localImage: cloudPost.image,
            localImageFileName: nil,
            likeCount: cloudPost.likes,
            commentCount: cloudPost.comments,
            shareCount: cloudPost.shares,
            isLiked: cloudPost.isLiked,
            isCustomPublication: true
        )
    }

    private func makeCloudPost(from item: HomeFeedPost) -> CloudPost {
        CloudPost(
            id: item.post.id,
            author: item.post.author,
            description: item.post.description,
            likes: item.likeCount,
            views: item.post.views,
            comments: item.commentCount,
            shares: item.shareCount,
            isLiked: item.isLiked,
            image: item.localImage,
            createdAt: Date()
        )
    }

    private func syncCustomPostToCloud(_ item: HomeFeedPost) {
        guard item.isCustomPublication else { return }
        cloudPostsService?.upsert(post: makeCloudPost(from: item), completion: nil)
    }

    private func removeCustomPostFromCloud(postId: String) {
        cloudPostsService?.delete(postId: postId, completion: nil)
    }

    private func uploadCachedPostsToCloudIfNeeded() {
        feed.filter { $0.isCustomPublication }.forEach { syncCustomPostToCloud($0) }
    }

    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let directory = documentsDirectory(),
              let data = image.jpegData(compressionQuality: 0.9) else { return nil }

        let fileName = "post_\(UUID().uuidString).jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            return nil
        }
    }

    private func loadImageFromDocuments(named fileName: String) -> UIImage? {
        guard let directory = documentsDirectory() else { return nil }
        let fileURL = directory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }

    private func removeImageFromDocuments(named fileName: String) {
        guard let directory = documentsDirectory() else { return }
        let fileURL = directory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func presentEditPostDialog(postId: String) {
        guard let currentIndex = feed.firstIndex(where: { $0.post.id == postId }) else { return }
        let item = feed[currentIndex]
        guard item.isCustomPublication else { return }

        let alert = UIAlertController(
            title: L10n.tr("home.post.edit_title"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = L10n.tr("home.post.description_placeholder")
            textField.text = item.post.description
        }
        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.tr("common.save"), style: .default) { [weak self] _ in
            guard let self else { return }
            guard let updateIndex = self.feed.firstIndex(where: { $0.post.id == postId }) else { return }

            let newDescription = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let text = (newDescription?.isEmpty == false) ? newDescription! : self.feed[updateIndex].post.description

            let oldPost = self.feed[updateIndex].post
            let updatedPost = Post(
                id: oldPost.id,
                author: oldPost.author,
                description: text,
                image: oldPost.image,
                likes: self.feed[updateIndex].likeCount,
                views: oldPost.views
            )
            self.feed[updateIndex].post = updatedPost
            self.persistCustomPublications()
            self.syncCustomPostToCloud(self.feed[updateIndex])
            self.tableView.reloadRows(at: [IndexPath(row: updateIndex, section: 0)], with: .automatic)
        })
        present(alert, animated: true)
    }

    private func deleteCustomPost(postId: String) {
        guard let deleteIndex = feed.firstIndex(where: { $0.post.id == postId }) else { return }
        let item = feed[deleteIndex]
        guard item.isCustomPublication else { return }

        if let fileName = item.localImageFileName {
            removeImageFromDocuments(named: fileName)
        }

        removeCustomPostFromCloud(postId: item.post.id)
        feed.remove(at: deleteIndex)
        persistCustomPublications()

        if feed.isEmpty {
            tableView.reloadData()
            stateView.apply(.empty(L10n.tr("home.state.empty")))
        } else {
            tableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HomePostCell.identifier,
            for: indexPath
        ) as! HomePostCell

        cell.configure(with: feed[indexPath.row])
        cell.onLikeTap = { [weak self] in
            self?.toggleLike(at: indexPath.row)
        }
        cell.onCommentTap = { [weak self] in
            self?.addComment(at: indexPath.row)
        }
        cell.onShareTap = { [weak self] in
            self?.sharePost(at: indexPath.row)
        }

        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard feed.indices.contains(indexPath.row) else { return }
        let item = feed[indexPath.row]
        guard item.isCustomPublication else { return }

        let sheet = UIAlertController(
            title: L10n.tr("home.post.sheet_title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: L10n.tr("home.post.edit_description"), style: .default) { [weak self] _ in
            self?.presentEditPostDialog(postId: item.post.id)
        })
        sheet.addAction(UIAlertAction(title: L10n.tr("home.post.delete"), style: .destructive) { [weak self] _ in
            self?.deleteCustomPost(postId: item.post.id)
        })
        sheet.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))

        if let popover = sheet.popoverPresentationController,
           let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(sheet, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard feed.indices.contains(indexPath.row), feed[indexPath.row].isCustomPublication else {
            return nil
        }
        let postId = feed[indexPath.row].post.id

        let delete = UIContextualAction(style: .destructive, title: L10n.tr("common.delete")) { [weak self] _, _, completion in
            self?.deleteCustomPost(postId: postId)
            completion(true)
        }

        let edit = UIContextualAction(style: .normal, title: L10n.tr("common.edit")) { [weak self] _, _, completion in
            self?.presentEditPostDialog(postId: postId)
            completion(true)
        }
        edit.backgroundColor = StyleGuide.Colors.accent

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            stateView.apply(.error(L10n.tr("home.error.load_photo")))
            return
        }

        pendingImageForPost = image
        presentCreatePostDialog()
    }
}
