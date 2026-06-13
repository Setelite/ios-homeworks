import UIKit
import AVFoundation

final class SearchViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let stateView = ScreenStateView()
    private let segmentedControl = UISegmentedControl(items: [
        L10n.tr("search.segment.music")
    ])

    private let playerContainer = UIView()
    private let playerTitleLabel = UILabel()
    private let playerSubtitleLabel = UILabel()
    private let playPauseButton = UIButton(type: .system)

    private var player: AVPlayer?
    private var isPlaying = false

    private let viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(viewModel: SearchViewModel())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.search")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupSearch()
        setupSegment()
        setupPlayer()
        setupTableView()
        setupStateView()
        bindViewModel()

        viewModel.load()
    }

    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = L10n.tr("search.placeholder")
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupSegment() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        tableView.separatorColor = StyleGuide.Colors.border
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: playerContainer.topAnchor, constant: -8)
        ])
    }

    private func setupPlayer() {
        playerContainer.translatesAutoresizingMaskIntoConstraints = false
        playerContainer.backgroundColor = StyleGuide.Colors.backgroundSecondary
        playerContainer.layer.cornerRadius = 12
        playerContainer.isHidden = true

        playerTitleLabel.font = StyleGuide.Fonts.body(14, weight: .semibold)
        playerTitleLabel.textColor = StyleGuide.Colors.textPrimary
        playerTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        playerSubtitleLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        playerSubtitleLabel.textColor = StyleGuide.Colors.textSecondary
        playerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        playPauseButton.setTitle(L10n.tr("search.player.play"), for: .normal)
        playPauseButton.titleLabel?.font = StyleGuide.Fonts.body(14, weight: .semibold)
        playPauseButton.tintColor = StyleGuide.Colors.accent
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        view.addSubview(playerContainer)
        playerContainer.addSubview(playerTitleLabel)
        playerContainer.addSubview(playerSubtitleLabel)
        playerContainer.addSubview(playPauseButton)

        NSLayoutConstraint.activate([
            playerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            playerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            playerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            playerContainer.heightAnchor.constraint(equalToConstant: 70),

            playerTitleLabel.topAnchor.constraint(equalTo: playerContainer.topAnchor, constant: 10),
            playerTitleLabel.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor, constant: 12),
            playerTitleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -12),

            playerSubtitleLabel.topAnchor.constraint(equalTo: playerTitleLabel.bottomAnchor, constant: 4),
            playerSubtitleLabel.leadingAnchor.constraint(equalTo: playerTitleLabel.leadingAnchor),
            playerSubtitleLabel.trailingAnchor.constraint(equalTo: playerTitleLabel.trailingAnchor),

            playPauseButton.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor, constant: -12),
            playPauseButton.centerYAnchor.constraint(equalTo: playerContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 90)
        ])
    }

    private func setupStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateView)
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: tableView.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])

        stateView.onRetry = { [weak self] in
            self?.viewModel.load()
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.stateView.apply(state)
        }

        viewModel.onItemsChange = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onTrackSelected = { [weak self] track in
            self?.play(track: track)
        }
    }

    private func play(track: MusicTrack?) {
        guard let track else {
            player?.pause()
            player = nil
            isPlaying = false
            playerContainer.isHidden = true
            return
        }

        player = AVPlayer(url: track.previewURL)
        isPlaying = false

        playerTitleLabel.text = track.title
        playerSubtitleLabel.text = track.artist
        playPauseButton.setTitle(L10n.tr("search.player.play"), for: .normal)
        playerContainer.isHidden = false
    }

    @objc private func playPauseTapped() {
        guard let player else { return }

        if isPlaying {
            player.pause()
            playPauseButton.setTitle(L10n.tr("search.player.play"), for: .normal)
        } else {
            player.play()
            playPauseButton.setTitle(L10n.tr("search.player.pause"), for: .normal)
        }
        isPlaying.toggle()
    }

    @objc private func segmentChanged() {
        viewModel.updateSegment(index: segmentedControl.selectedSegmentIndex)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearch(text: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = viewModel.items[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.textProperties.color = StyleGuide.Colors.textPrimary
        config.secondaryTextProperties.color = StyleGuide.Colors.textSecondary

        if case .track(let track) = item {
            config.text = track.title
            config.secondaryText = "\(track.artist) • \(L10n.tr("search.track.preview"))"
            config.image = UIImage(systemName: "music.note")
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = config
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard viewModel.items.indices.contains(indexPath.row) else { return }
        viewModel.selectItem(at: indexPath.row)
    }
}
