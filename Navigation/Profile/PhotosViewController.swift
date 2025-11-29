//
//  PhotosViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 18.08.2025.
//
import UIKit
import iOSIntPackage

final class PhotosViewController: UIViewController {

    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()

    // MARK: - Data
    var photos: [String] = []
    private var publishedImages: [UIImage] = []

    // MARK: - Publisher
    private let imagePublisherFacade = ImagePublisherFacade()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Photo Gallery"

        setupTabBar()
        setupCollectionView()

        // подписка
        imagePublisherFacade.subscribe(self)

        // UIImage из строк photos
        let uiImages = photos.compactMap { UIImage(named: $0) }

        // запуск таймера
        imagePublisherFacade.addImagesWithTimer(
            time: 0.5,
            repeat: 15,
            userImages: uiImages
        )
    }

    deinit {
        // отписка
        imagePublisherFacade.removeSubscription(for: self)
    }

    // MARK: - UI setup
    private func setupTabBar() {
        tabBarController?.tabBar.barTintColor = .systemGray6
        tabBarController?.tabBar.backgroundColor = .systemGray6
        tabBarController?.tabBar.layer.borderColor = UIColor.systemGray3.cgColor
        tabBarController?.tabBar.layer.borderWidth = 0.5
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            PhotosCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotosCollectionViewCell.reuseIdentifier
        )
    }
}

// MARK: - CollectionView Delegate & DataSource
extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(photos.count, publishedImages.count)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotosCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! PhotosCollectionViewCell

        if indexPath.item < publishedImages.count {
            cell.configure(with: publishedImages[indexPath.item])
            return cell
        }

        if indexPath.item < photos.count {
            cell.configure(with: photos[indexPath.item])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 8
        let totalSpacing = spacing * 2
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = floor(availableWidth / 3)

        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - ImageLibrarySubscriber
extension PhotosViewController: ImageLibrarySubscriber {

    func receive(images: [UIImage]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.publishedImages.append(contentsOf: images)
            self.collectionView.reloadData()
        }
    }
}
