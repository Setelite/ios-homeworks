import UIKit

final class ChatsViewController: UIViewController {
    private struct ChatItem {
        let name: String
        let lastMessage: String
        let time: String
    }

    private let tableView = UITableView()
    private let stateView = ScreenStateView()
    private var chats: [ChatItem] = [
        ChatItem(name: L10n.tr("chat.item.netology.name"), lastMessage: L10n.tr("chat.item.netology.message"), time: "12:40"),
        ChatItem(name: "iOS Team", lastMessage: L10n.tr("chat.item.team.message"), time: "11:05"),
        ChatItem(name: L10n.tr("chat.item.friends.name"), lastMessage: L10n.tr("chat.item.friends.message"), time: L10n.tr("chat.time.yesterday")),
        ChatItem(name: "Maxim", lastMessage: L10n.tr("chat.item.maxim.message"), time: L10n.tr("chat.time.yesterday"))
    ]

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.chats.isEmpty {
                self.stateView.apply(.empty(L10n.tr("chats.state.empty")))
            } else {
                self.tableView.reloadData()
                self.stateView.apply(.content)
            }
        }
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
        let vc = ChatDetailViewController(title: chats[indexPath.row].name)
        navigationController?.pushViewController(vc, animated: true)
    }
}
