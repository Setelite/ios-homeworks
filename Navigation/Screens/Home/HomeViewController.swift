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
        let imageFileName: String?
        let remoteImageURL: String?
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
    private let refreshControl = UIRefreshControl()
    private let favoritesRepository = FavoritesRepository.shared
    private let interactionsStore: FeedInteractionsStoreProtocol
    private let remoteFeedViewModel: SocialFeedViewModel
    private let cloudPostsService: CloudPostsService? = {
        guard FeatureFlags.cloudSyncEnabled else { return nil }
        return CloudPostsService(container: .default())
    }()
    private let stateView = ScreenStateView()
    private var avatarImage: UIImage?
    private var pendingImageForPost: UIImage?
    private var isSkeletonLoading = true
    private var remoteFeed: [HomeFeedPost] = []
    private var customFeed: [HomeFeedPost] = []
    private var autoRefreshTimer: Timer?
    private var noInternetWorkItem: DispatchWorkItem?
    private var lastNoInternetAlertDate: Date?
    private var selectedGenre: FeedGenre = .humor
    var onOpenProfile: (() -> Void)?

    private var stories: [StoryItem] = [
        StoryItem(id: UUID().uuidString, name: "Maxim", imageName: "my_photo"),
        StoryItem(id: UUID().uuidString, name: "Dady", imageName: "hulk"),
        StoryItem(id: UUID().uuidString, name: "Plein", imageName: "pp"),
        StoryItem(id: UUID().uuidString, name: "Swift", imageName: "skala"),
        StoryItem(id: UUID().uuidString, name: "Netology", imageName: "avatar")
    ]

    // Итоговая лента = пользовательские публикации + посты из API.
    private var feed: [HomeFeedPost] = []

    init(
        remoteFeedViewModel: SocialFeedViewModel = SocialFeedViewModel(
            service: CatFeedService(),
            cacheRepository: CoreDataFeedCacheRepository()
        ),
        interactionsStore: FeedInteractionsStoreProtocol = FeedInteractionsStore()
    ) {
        self.remoteFeedViewModel = remoteFeedViewModel
        self.interactionsStore = interactionsStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.home")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupNavigationBar()
        setupTableView()
        setupStoriesHeader()
        setupStateView()
        stateView.onRetry = { [weak self] in
            self?.requestRemoteFeed(isRefresh: false)
        }
        remoteFeedViewModel.setGenre(selectedGenre)
        bindRemoteFeedViewModel()
        loadCustomPublications()

        requestRemoteFeed(isRefresh: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = currentUser()
        configureAvatar(user?.avatar)
        startAutoFeedRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoFeedRefresh()
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
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl

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
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addPostTapped)
        )
        navigationItem.rightBarButtonItem = addButton
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
        if feed.isEmpty {
            stateView.apply(.empty(L10n.tr("home.state.empty")))
        } else {
            tableView.reloadData()
            stateView.apply(.content)
        }
    }

    private func bindRemoteFeedViewModel() {
        remoteFeedViewModel.onStateChange = { [weak self] state in
            self?.renderRemoteState(state)
        }
    }

    private func renderRemoteState(_ state: SocialFeedViewModel.State) {
        switch state {
        case .idle:
            break
        case .loading:
            isSkeletonLoading = true
            scheduleNoInternetWarningIfNeeded()
            stateView.apply(.loading(L10n.tr("home.state.loading")))
            tableView.reloadData()
        case .content(let posts):
            noInternetWorkItem?.cancel()
            isSkeletonLoading = false
            remoteFeed = posts.map(mapRemotePost)
            rebuildFeed()
            refreshControl.endRefreshing()
        case .error(let message):
            noInternetWorkItem?.cancel()
            isSkeletonLoading = false
            refreshControl.endRefreshing()

            if feed.isEmpty {
                stateView.apply(.error(message))
            } else {
                stateView.apply(.content)
            }
            tableView.reloadData()
        }
    }

    private func mapRemotePost(_ post: SocialFeedPost) -> HomeFeedPost {
        let interaction = interactionsStore.snapshot(for: post.id, userID: currentUserID())
        let generated = Post(
            id: post.id,
            author: post.username,
            description: post.caption,
            image: "my_photo",
            likes: interaction.likesCount,
            views: Int.random(in: 300...7000)
        )

        return HomeFeedPost(
            post: generated,
            avatarURL: post.avatarURL,
            publishedAt: post.date,
            localImage: nil,
            localImageFileName: nil,
            remoteImageURL: post.photoURL,
            likeCount: interaction.likesCount,
            commentCount: interaction.commentsCount,
            shareCount: interaction.sharesCount,
            isLiked: interaction.isLiked,
            isCustomPublication: false
        )
    }

    private func rebuildFeed() {
        feed = customFeed + remoteFeed
        loadContent()
    }

    @objc private func refreshPulled() {
        requestRemoteFeed(isRefresh: true)
    }

    private func requestRemoteFeed(isRefresh: Bool) {
        Task { [weak self] in
            guard let self else { return }
            if isRefresh {
                await remoteFeedViewModel.refresh()
            } else {
                await remoteFeedViewModel.loadInitial()
            }
        }
    }

    private func startAutoFeedRefresh() {
        stopAutoFeedRefresh()
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            self?.requestRemoteFeed(isRefresh: true)
        }
    }

    private func stopAutoFeedRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    private func toggleLike(at index: Int) {
        guard feed.indices.contains(index) else { return }

        if feed[index].isCustomPublication {
            feed[index].isLiked.toggle()
            feed[index].likeCount += feed[index].isLiked ? 1 : -1
            syncCustomFeedItem(feed[index])
            persistCustomPublications()
            syncCustomPostToCloud(feed[index])
        } else {
            let snapshot = interactionsStore.toggleLike(for: feed[index].post.id, userID: currentUserID())
            feed[index].isLiked = snapshot.isLiked
            feed[index].likeCount = snapshot.likesCount

            if snapshot.isLiked {
                favoritesRepository.save(post: feed[index].post)
            } else {
                favoritesRepository.remove(id: feed[index].post.id)
            }
        }

        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func addComment(at index: Int) {
        guard feed.indices.contains(index) else { return }
        presentCommentDialog(at: index)
    }

    private func sharePost(at index: Int) {
        guard feed.indices.contains(index) else { return }

        if feed[index].isCustomPublication {
            feed[index].shareCount += 1
        } else {
            let snapshot = interactionsStore.incrementShare(for: feed[index].post.id, userID: currentUserID())
            feed[index].shareCount = snapshot.sharesCount
        }

        let activity = UIActivityViewController(
            activityItems: [feed[index].post.description],
            applicationActivities: nil
        )
        present(activity, animated: true)

        if feed[index].isCustomPublication {
            syncCustomFeedItem(feed[index])
            persistCustomPublications()
            syncCustomPostToCloud(feed[index])
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func presentCommentDialog(at index: Int) {
        let alert = UIAlertController(
            title: L10n.tr("home.post.comment_title"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = L10n.tr("home.post.comment_placeholder")
        }
        alert.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.tr("home.post.publish"), style: .default) { [weak self] _ in
            guard let self else { return }
            guard self.feed.indices.contains(index) else { return }
            let text = alert.textFields?.first?.text ?? ""

            if self.feed[index].isCustomPublication {
                self.feed[index].commentCount += 1
                self.syncCustomFeedItem(self.feed[index])
                self.persistCustomPublications()
                self.syncCustomPostToCloud(self.feed[index])
            } else {
                let snapshot = self.interactionsStore.addComment(
                    for: self.feed[index].post.id,
                    userID: self.currentUserID(),
                    text: text
                )
                self.feed[index].commentCount = snapshot.commentsCount
            }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        })
        present(alert, animated: true)
    }

    private func currentUserID() -> String {
        FirebaseSessionStorage.shared.user?.email.lowercased() ?? "guest"
    }

    private func scheduleNoInternetWarningIfNeeded() {
        noInternetWorkItem?.cancel()
        guard feed.isEmpty else { return }

        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.feed.isEmpty else { return }
            let now = Date()
            if let last = self.lastNoInternetAlertDate,
               now.timeIntervalSince(last) < 60 {
                return
            }

            self.lastNoInternetAlertDate = now
            let alert = UIAlertController(
                title: L10n.tr("common.error"),
                message: L10n.tr("home.error.long_no_internet"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: L10n.tr("common.ok"), style: .default))
            if self.presentedViewController == nil {
                self.present(alert, animated: true)
            }
        }

        noInternetWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: work)
    }

    private func openStory(at index: Int) {
        let viewer = StoryViewerViewController(stories: stories, initialIndex: index)
        present(viewer, animated: true)
    }

    @objc private func addPostTapped() {
        let sheet = UIAlertController(
            title: L10n.tr("home.post.create_source"),
            message: nil,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: L10n.tr("home.post.from_gallery"), style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        sheet.addAction(UIAlertAction(title: L10n.tr("common.cancel"), style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(sheet, animated: true)
    }

    @objc private func profileTapped() {
        if let onOpenProfile {
            onOpenProfile()
            return
        }

        let user = currentUser()
        let vm = ProfileViewModel(user: user)
        let profileVC = ProfileViewController(
            viewModel: vm,
            screenMode: .myProfile
        )
        navigationController?.pushViewController(profileVC, animated: true)
    }

    private func currentUser() -> User? {
        let userService = CurrentUserService()
        if let email = FirebaseSessionStorage.shared.user?.email,
           let user = userService.getUser(login: email) {
            return user
        }

        return userService.getUser(login: "Wowgorno")
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
            image: "my_photo",
            likes: 0,
            views: 0
        )

        customFeed.insert(
            HomeFeedPost(
                post: newPost,
                avatarURL: nil,
                publishedAt: Date(),
                localImage: image,
                localImageFileName: imageFileName,
                remoteImageURL: nil,
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
        if let newest = customFeed.first {
            syncCustomPostToCloud(newest)
        }
        rebuildFeed()
    }

    private func persistCustomPublications() {
        // сохранения сообщений в ленте автора
        let stored: [StoredPublication] = Array(customFeed.compactMap { item in
            return StoredPublication(
                id: item.post.id,
                author: item.post.author,
                description: item.post.description,
                imageFileName: item.localImageFileName,
                remoteImageURL: item.remoteImageURL?.absoluteString,
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
            let image = item.imageFileName.flatMap { loadImageFromDocuments(named: $0) }
            let post = Post(
                id: item.id,
                author: item.author,
                description: item.description,
                image: "my_photo",
                likes: item.likes,
                views: item.views
            )
            return HomeFeedPost(
                post: post,
                avatarURL: nil,
                publishedAt: Date(),
                localImage: image,
                localImageFileName: item.imageFileName,
                remoteImageURL: item.remoteImageURL.flatMap { URL(string: $0) },
                likeCount: item.likes,
                commentCount: item.comments,
                shareCount: item.shares,
                isLiked: item.isLiked,
                isCustomPublication: true
            )
        }

        customFeed = Array(loaded.prefix(3))
        rebuildFeed()
    }

    private func enforceCustomPostLimit(maxCount: Int) {
        guard maxCount > 0 else { return }

        guard customFeed.count > maxCount else { return }

        let toRemove = customFeed.dropFirst(maxCount)
        toRemove.forEach { item in
            if let fileName = item.localImageFileName {
                removeImageFromDocuments(named: fileName)
            }
            removeCustomPostFromCloud(postId: item.post.id)
        }
        customFeed = Array(customFeed.prefix(maxCount))
        rebuildFeed()
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

    private func syncCustomFeedItem(_ updated: HomeFeedPost) {
        guard let index = customFeed.firstIndex(where: { $0.post.id == updated.post.id }) else { return }
        customFeed[index] = updated
        rebuildFeed()
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
            self.syncCustomFeedItem(self.feed[updateIndex])
            self.persistCustomPublications()
            self.syncCustomPostToCloud(self.feed[updateIndex])
            self.tableView.reloadRows(at: [IndexPath(row: updateIndex, section: 0)], with: .automatic)
        })
        present(alert, animated: true)
    }

    private func deleteCustomPost(postId: String) {
        guard let item = feed.first(where: { $0.post.id == postId }) else { return }
        guard item.isCustomPublication else { return }

        if let fileName = item.localImageFileName {
            removeImageFromDocuments(named: fileName)
        }

        removeCustomPostFromCloud(postId: item.post.id)
        customFeed.removeAll { $0.post.id == item.post.id }
        persistCustomPublications()
        rebuildFeed()
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSkeletonLoading ? 4 : feed.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HomePostCell.identifier,
            for: indexPath
        ) as! HomePostCell

        if isSkeletonLoading {
            cell.configureSkeleton()
            cell.onLikeTap = nil
            cell.onCommentTap = nil
            cell.onShareTap = nil
            return cell
        }

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
        guard !isSkeletonLoading else { return }
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
