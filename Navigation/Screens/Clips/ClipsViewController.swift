import UIKit
import AVKit

final class ClipsViewController: UIViewController {
    private struct ClipItem {
        let title: String
        let streamURL: URL
    }

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // загружаются через интернет и воспроизводятся 
    private let remoteClipURLs: [String] = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
    ]
    private var clips: [ClipItem] = []
    private let stateView = ScreenStateView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("tab.clips")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = StyleGuide.Colors.backgroundPrimary
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "clipCell")

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setupStateView()
        stateView.onRetry = { [weak self] in
            self?.loadData()
        }
        loadData()
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
        stateView.apply(.loading(L10n.tr("clips.state.loading")))

        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = self.remoteClipURLs.enumerated().compactMap { index, urlString -> ClipItem? in
                guard let url = URL(string: urlString) else { return nil }
                return ClipItem(
                    title: L10n.format("clips.item_format", index + 1),
                    streamURL: url
                )
            }

            DispatchQueue.main.async {
                self.clips = loaded
                if self.clips.isEmpty {
                    self.stateView.apply(.empty(L10n.tr("clips.state.empty")))
                } else {
                    self.collectionView.reloadData()
                    self.stateView.apply(.content)
                }
            }
        }
    }
}

extension ClipsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        clips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clipCell", for: indexPath)
        cell.backgroundColor = StyleGuide.Colors.backgroundSecondary
        cell.layer.cornerRadius = 12

        let titleTag = 777
        let subtitleTag = 778

        let titleLabel: UILabel
        if let existing = cell.contentView.viewWithTag(titleTag) as? UILabel {
            titleLabel = existing
        } else {
            titleLabel = UILabel()
            titleLabel.tag = titleTag
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = StyleGuide.Fonts.body(16, weight: .semibold)
            titleLabel.textColor = StyleGuide.Colors.textPrimary
            titleLabel.textAlignment = .center
            cell.contentView.addSubview(titleLabel)
        }

        let subtitleLabel: UILabel
        if let existing = cell.contentView.viewWithTag(subtitleTag) as? UILabel {
            subtitleLabel = existing
        } else {
            subtitleLabel = UILabel()
            subtitleLabel.tag = subtitleTag
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
            subtitleLabel.textColor = StyleGuide.Colors.textSecondary
            subtitleLabel.textAlignment = .center
            subtitleLabel.text = L10n.tr("clips.remote")
            cell.contentView.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: -10),
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cell.contentView.leadingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cell.contentView.trailingAnchor, constant: -8),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                subtitleLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor)
            ])
        }

        titleLabel.text = clips[indexPath.item].title
        return cell
    }
}

extension ClipsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        let totalSpacing = (columns - 1) * 12
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width * 1.2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard clips.indices.contains(indexPath.item) else { return }
        let clip = clips[indexPath.item]

        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: clip.streamURL)
        playerVC.title = clip.title
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }
}
