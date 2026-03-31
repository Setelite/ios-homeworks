import UIKit

final class SearchViewController: UIViewController {
    private let tableView = UITableView()
    private let stateView = ScreenStateView()
    private var allPosts: [Post] = []
    private var filteredPosts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.search")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupSearch()
        setupTableView()
        setupStateView()
        stateView.onRetry = { [weak self] in
            self?.loadData()
        }
        loadData()
    }

    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = L10n.tr("tab.search")
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

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
        stateView.apply(.loading(L10n.tr("search.state.loading")))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.allPosts = PostProvider.makePosts()
            self.filteredPosts = self.allPosts

            if self.filteredPosts.isEmpty {
                self.stateView.apply(.empty(L10n.tr("search.state.empty")))
            } else {
                self.tableView.reloadData()
                self.stateView.apply(.content)
            }
        }
    }

    private func filter(with query: String) {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !normalized.isEmpty else {
            filteredPosts = allPosts
            tableView.reloadData()
            return
        }

        filteredPosts = allPosts.filter {
            $0.author.lowercased().contains(normalized)
            || $0.description.lowercased().contains(normalized)
        }
        tableView.reloadData()
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filter(with: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let post = filteredPosts[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = post.author
        config.secondaryText = post.description
        config.image = UIImage(systemName: "magnifyingglass")
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = PostViewController(post: filteredPosts[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
