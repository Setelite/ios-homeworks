import UIKit

final class MenuViewController: UIViewController {
    enum MenuAction: CaseIterable {
        case profile
        case sports
        case nutrition
        case favorites
        case files
        case settings
        case posts
        case info

        var title: String {
            switch self {
            case .profile: return L10n.tr("menu.profile")
            case .sports: return L10n.tr("menu.sports")
            case .nutrition: return L10n.tr("menu.nutrition")
            case .favorites: return L10n.tr("menu.favorites")
            case .files: return L10n.tr("menu.files")
            case .settings: return L10n.tr("menu.settings")
            case .posts: return L10n.tr("menu.posts")
            case .info: return L10n.tr("menu.info")
            }
        }

        var icon: String {
            switch self {
            case .profile: return "person.crop.circle"
            case .sports: return "figure.run.circle"
            case .nutrition: return "barcode.viewfinder"
            case .favorites: return "heart"
            case .files: return "folder"
            case .settings: return "gearshape"
            case .posts: return "doc.text.image"
            case .info: return "info.circle"
            }
        }
    }

    var onAction: ((MenuAction) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let stateView = ScreenStateView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.menu")
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")

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
        stateView.apply(.loading(L10n.tr("menu.state.loading")))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if MenuAction.allCases.isEmpty {
                self.stateView.apply(.empty(L10n.tr("menu.state.empty")))
            } else {
                self.tableView.reloadData()
                self.stateView.apply(.content)
            }
        }
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MenuAction.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        let action = MenuAction.allCases[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = action.title
        config.image = UIImage(systemName: action.icon)
        config.imageProperties.tintColor = StyleGuide.Colors.textSecondary
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onAction?(MenuAction.allCases[indexPath.row])
    }
}
