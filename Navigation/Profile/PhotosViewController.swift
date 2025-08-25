//
//  PhotosViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 18.08.2025.
//
import UIKit

final class PhotosViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8      // расстояние между рядами
        layout.minimumInteritemSpacing = 8 // расстояние между колонками
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    var photos: [String] = [
        "photo1", "photo2", "photo3", "photo4",
        "photo5", "photo6", "photo7", "photo8",
        "photo9", "photo10", "photo11", "photo12"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Photo Gallery"
        setupNavBar()
        setupCollectionView()
        setupTabBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6   // ✅ серый фон как в макете
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8), // ✅ 8pt сверху
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: "PhotosCell")
    }
    
    private func setupTabBar() {
        tabBarController?.tabBar.barTintColor = .systemGray6
        tabBarController?.tabBar.backgroundColor = .systemGray6
        tabBarController?.tabBar.layer.borderColor = UIColor.systemGray3.cgColor
        tabBarController?.tabBar.layer.borderWidth = 0.5
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCollectionViewCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 2   // между 3 ячейками = 2 промежутка
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = floor(availableWidth / 3)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
