import UIKit
import AVFoundation

final class MyMusicViewController: UIViewController {
    private let viewModel: MyMusicViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let stateView = ScreenStateView()

    private let controlsContainer = UIView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let rewindButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private var player: AVPlayer?
    private var currentIndex: Int = 0
    private var isPlaying = false

    init(viewModel: MyMusicViewModel = MyMusicViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("music.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupTableView()
        setupControls()
        setupStateView()
        bindViewModel()
        viewModel.load()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 58
        tableView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "trackCell")

        view.addSubview(tableView)
    }

    private func setupControls() {
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.backgroundColor = StyleGuide.Colors.backgroundSecondary
        controlsContainer.layer.cornerRadius = 14

        titleLabel.font = StyleGuide.Fonts.body(14, weight: .semibold)
        titleLabel.textColor = StyleGuide.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        artistLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        artistLabel.textColor = StyleGuide.Colors.textSecondary
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        configureButton(previousButton, title: "⏮", action: #selector(previousTapped))
        configureButton(rewindButton, title: "-10", action: #selector(rewindTapped))
        configureButton(playPauseButton, title: L10n.tr("music.control.play"), action: #selector(playPauseTapped))
        configureButton(stopButton, title: L10n.tr("music.control.stop"), action: #selector(stopTapped))
        configureButton(forwardButton, title: "+10", action: #selector(forwardTapped))
        configureButton(nextButton, title: "⏭", action: #selector(nextTapped))

        let controlsStack = UIStackView(arrangedSubviews: [previousButton, rewindButton, playPauseButton, stopButton, forwardButton, nextButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 6
        controlsStack.distribution = .fillEqually
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsContainer)
        controlsContainer.addSubview(titleLabel)
        controlsContainer.addSubview(artistLabel)
        controlsContainer.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            controlsContainer.heightAnchor.constraint(equalToConstant: 124),

            titleLabel.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -12),

            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            controlsStack.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 10),
            controlsStack.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 8),
            controlsStack.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -8),
            controlsStack.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: -8)
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
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
            guard let self else { return }
            if !self.viewModel.tracks.isEmpty {
                self.prepareTrack(at: self.currentIndex)
            }
        }

        viewModel.onStateChange = { [weak self] state in
            self?.stateView.apply(state)
        }
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = StyleGuide.Fonts.caption(12, weight: .semibold)
        button.tintColor = StyleGuide.Colors.accent
        button.backgroundColor = StyleGuide.Colors.card
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private func prepareTrack(at index: Int) {
        guard viewModel.tracks.indices.contains(index) else { return }
        currentIndex = index
        let track = viewModel.tracks[index]
        player = AVPlayer(url: track.previewURL)
        isPlaying = false
        titleLabel.text = track.title
        artistLabel.text = track.artist
        playPauseButton.setTitle(L10n.tr("music.control.play"), for: .normal)
    }

    @objc private func previousTapped() {
        guard !viewModel.tracks.isEmpty else { return }
        let nextIndex = (currentIndex - 1 + viewModel.tracks.count) % viewModel.tracks.count
        prepareTrack(at: nextIndex)
        startPlayback()
        isPlaying = true
    }

    @objc private func nextTapped() {
        guard !viewModel.tracks.isEmpty else { return }
        let nextIndex = (currentIndex + 1) % viewModel.tracks.count
        prepareTrack(at: nextIndex)
        startPlayback()
        isPlaying = true
    }

    @objc private func rewindTapped() {
        guard let player else { return }
        let current = player.currentTime().seconds
        let target = max(current - 10, 0)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    @objc private func forwardTapped() {
        guard let player else { return }
        let current = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? current + 10
        let target = min(current + 10, duration)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    @objc private func stopTapped() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        playPauseButton.setTitle(L10n.tr("music.control.play"), for: .normal)
    }

    @objc private func playPauseTapped() {
        if isPlaying {
            player?.pause()
            playPauseButton.setTitle(L10n.tr("music.control.play"), for: .normal)
        } else {
            startPlayback()
        }
        isPlaying.toggle()
    }

    private func startPlayback() {
        player?.play()
        playPauseButton.setTitle(L10n.tr("music.control.pause"), for: .normal)
    }
}

extension MyMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath)
        let track = viewModel.tracks[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = track.title
        config.secondaryText = track.artist
        config.image = UIImage(systemName: "music.note")
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension MyMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        prepareTrack(at: indexPath.row)
        startPlayback()
        isPlaying = true
    }
}
