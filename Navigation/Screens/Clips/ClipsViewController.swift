import UIKit
import AVFoundation

final class ClipsViewController: UIViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let stateView = ScreenStateView()
    private let controlsContainer = UIView()
    private let trackTitleLabel = UILabel()
    private let artistLabel = UILabel()

    private let previousButton = UIButton(type: .system)
    private let rewindButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private let service: MusicCatalogServiceProtocol = MusicCatalogService()
    private var tracks: [MusicTrack] = []
    private var player: AVPlayer?
    private var currentIndex: Int = 0
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.music")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupCollectionView()
        setupControls()
        setupStateView()

        stateView.onRetry = { [weak self] in
            self?.loadData()
        }

        loadData()
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MusicCoverCell.self, forCellWithReuseIdentifier: MusicCoverCell.identifier)

        view.addSubview(collectionView)
    }

    private func setupControls() {
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.backgroundColor = StyleGuide.Colors.backgroundSecondary
        controlsContainer.layer.cornerRadius = 14

        trackTitleLabel.font = StyleGuide.Fonts.body(14, weight: .semibold)
        trackTitleLabel.textColor = StyleGuide.Colors.textPrimary
        trackTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        artistLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        artistLabel.textColor = StyleGuide.Colors.textSecondary
        artistLabel.translatesAutoresizingMaskIntoConstraints = false

        configureControl(previousButton, systemName: "backward.end.fill", action: #selector(previousTapped))
        configureControl(rewindButton, systemName: "gobackward.10", action: #selector(rewindTapped))
        configureControl(playPauseButton, systemName: "play.fill", action: #selector(playPauseTapped))
        configureControl(stopButton, systemName: "stop.fill", action: #selector(stopTapped))
        configureControl(forwardButton, systemName: "goforward.10", action: #selector(forwardTapped))
        configureControl(nextButton, systemName: "forward.end.fill", action: #selector(nextTapped))

        let controlsStack = UIStackView(arrangedSubviews: [previousButton, rewindButton, playPauseButton, stopButton, forwardButton, nextButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 8
        controlsStack.distribution = .fillEqually
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsContainer)
        controlsContainer.addSubview(trackTitleLabel)
        controlsContainer.addSubview(artistLabel)
        controlsContainer.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            controlsContainer.heightAnchor.constraint(equalToConstant: 126),

            trackTitleLabel.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 10),
            trackTitleLabel.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 12),
            trackTitleLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -12),

            artistLabel.topAnchor.constraint(equalTo: trackTitleLabel.bottomAnchor, constant: 2),
            artistLabel.leadingAnchor.constraint(equalTo: trackTitleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: trackTitleLabel.trailingAnchor),

            controlsStack.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 10),
            controlsStack.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 8),
            controlsStack.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -8),
            controlsStack.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: -8)
        ])
    }

    private func setupStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateView)
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }

    private func configureControl(_ button: UIButton, systemName: String, action: Selector) {
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = StyleGuide.Colors.accent
        button.backgroundColor = StyleGuide.Colors.card
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private func loadData() {
        stateView.apply(.loading(L10n.tr("music.state.loading")))

        Task {
            do {
                let loaded = try await service.fetchTracks(query: "top hits 2026", limit: 50)
                await MainActor.run {
                    self.tracks = loaded
                    self.collectionView.reloadData()
                    if loaded.isEmpty {
                        self.stateView.apply(.empty(L10n.tr("music.state.empty")))
                    } else {
                        self.prepareTrack(at: 0)
                        self.stateView.apply(.content)
                    }
                }
            } catch {
                await MainActor.run {
                    self.stateView.apply(.error(L10n.tr("music.state.error")))
                }
            }
        }
    }

    private func prepareTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentIndex = index
        let track = tracks[index]
        player = AVPlayer(url: track.previewURL)
        isPlaying = false
        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }

    private func startPlayback() {
        player?.play()
        isPlaying = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }

    @objc private func previousTapped() {
        guard !tracks.isEmpty else { return }
        let next = (currentIndex - 1 + tracks.count) % tracks.count
        prepareTrack(at: next)
        startPlayback()
    }

    @objc private func nextTapped() {
        guard !tracks.isEmpty else { return }
        let next = (currentIndex + 1) % tracks.count
        prepareTrack(at: next)
        startPlayback()
    }

    @objc private func rewindTapped() {
        guard let player else { return }
        let target = max(0, player.currentTime().seconds - 10)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    @objc private func forwardTapped() {
        guard let player else { return }
        let current = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? current + 10
        let target = min(duration, current + 10)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    @objc private func stopTapped() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }

    @objc private func playPauseTapped() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            isPlaying = true
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
}

extension ClipsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tracks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCoverCell.identifier, for: indexPath) as! MusicCoverCell
        cell.configure(with: tracks[indexPath.item])
        return cell
    }
}

extension ClipsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        let totalSpacing = (columns - 1) * 12
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width + 54)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        prepareTrack(at: indexPath.item)
        startPlayback()
    }
}

final class MusicCoverCell: UICollectionViewCell {
    static let identifier = "MusicCoverCell"

    private let artworkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()

    private var task: URLSessionDataTask?
    private static let cache = NSCache<NSURL, UIImage>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        artworkImageView.image = UIImage(systemName: "music.note")
    }

    func configure(with track: MusicTrack) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        loadArtwork(url: track.artworkURL)
    }

    private func setupUI() {
        backgroundColor = StyleGuide.Colors.card
        layer.cornerRadius = 12
        layer.borderWidth = 0.5
        layer.borderColor = StyleGuide.Colors.border.cgColor

        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.clipsToBounds = true
        artworkImageView.layer.cornerRadius = 10
        artworkImageView.image = UIImage(systemName: "music.note")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = StyleGuide.Fonts.caption(12, weight: .semibold)
        titleLabel.textColor = StyleGuide.Colors.textPrimary
        titleLabel.numberOfLines = 1

        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = StyleGuide.Fonts.caption(11, weight: .regular)
        artistLabel.textColor = StyleGuide.Colors.textSecondary
        artistLabel.numberOfLines = 1

        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)

        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artworkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: artworkImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: artworkImageView.trailingAnchor),

            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    private func loadArtwork(url: URL?) {
        task?.cancel()
        task = nil

        guard let url else {
            artworkImageView.image = UIImage(systemName: "music.note")
            return
        }

        let nsURL = url as NSURL
        if let cached = Self.cache.object(forKey: nsURL) {
            artworkImageView.image = cached
            return
        }

        artworkImageView.image = UIImage(systemName: "music.note")
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else { return }
            Self.cache.setObject(image, forKey: nsURL)
            DispatchQueue.main.async {
                self.artworkImageView.image = image
            }
        }
        task?.resume()
    }
}
