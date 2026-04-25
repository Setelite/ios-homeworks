import UIKit

final class ChatsViewController: UIViewController {
    private struct ChatItem {
        let name: String
        let roomID: String
        let lastMessage: String
        let time: String
    }

    private let tableView = UITableView()
    private let stateView = ScreenStateView()
    private let chatService: FirebaseChatServiceProtocol
    private let userProfileService: FirebaseUserProfileServiceProtocol
    private var peers: [String] = []

    private var chats: [ChatItem] = []

    init(
        chatService: FirebaseChatServiceProtocol = FirebaseChatService(),
        userProfileService: FirebaseUserProfileServiceProtocol = FirebaseUserProfileService()
    ) {
        self.chatService = chatService
        self.userProfileService = userProfileService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.chats")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupTableView()
        setupStateView()
        stateView.onRetry = { [weak self] in
            self?.loadData()
        }
        loadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    private func loadData() {
        stateView.apply(.loading(L10n.tr("chats.state.loading")))

        guard let token = FirebaseSessionStorage.shared.token,
              let currentUser = FirebaseSessionStorage.shared.user?.email else {
            let fallbackPeers = defaultPeers()
            chats = fallbackPeers.map {
                ChatItem(
                    name: $0,
                    roomID: FirebaseChatService.roomID(currentUser: "guest", peer: $0),
                    lastMessage: L10n.tr("chat.placeholder.no_messages"),
                    time: ""
                )
            }
            tableView.reloadData()
            stateView.apply(.content)
            return
        }

        Task {
            let remotePeers = (try? await userProfileService.fetchUserEmails(idToken: token, excluding: currentUser)) ?? []
            self.peers = remotePeers.isEmpty ? self.defaultPeers() : remotePeers
            let dialogs = (try? await chatService.fetchDialogs(currentUser: currentUser, peers: self.peers, token: token)) ?? []
            await MainActor.run {
                self.chats = dialogs.map {
                    ChatItem(name: $0.peerName, roomID: $0.roomID, lastMessage: $0.lastMessage, time: $0.time)
                }

                if self.chats.isEmpty {
                    self.stateView.apply(.empty(L10n.tr("chats.state.empty")))
                } else {
                    self.tableView.reloadData()
                    self.stateView.apply(.content)
                }
            }
        }
    }

    private func defaultPeers() -> [String] {
        [
            L10n.tr("chat.item.netology.name"),
            "ios.team@platform.app",
            L10n.tr("chat.item.friends.name"),
            "maxim@platform.app"
        ]
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let chat = chats[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = chat.name
        config.secondaryText = "\(chat.lastMessage)  •  \(chat.time)"
        config.image = UIImage(systemName: "person.crop.circle.fill")
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard chats.indices.contains(indexPath.row) else { return }
        let item = chats[indexPath.row]
        let vc = ChatDetailViewController(title: item.name, roomID: item.roomID)
        navigationController?.pushViewController(vc, animated: true)
    }
}
