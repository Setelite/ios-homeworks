//
//  PhotosViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 18.08.2025.
//
import UIKit
import iOSIntPackage

final class PhotosViewController: UIViewController {
    
    // MARK: - Input from coordinator
    var photos: [String] = [] {
        didSet {
            guard isViewLoaded else { return }
            startProcessing()
        }
    }
    
    // MARK: - Image storage
    private var sourceImages: [UIImage] = []
    private var processedImages: [UIImage] = []
    
    private let qosLevels: [QualityOfService] = [
        .userInteractive,
        .userInitiated,
        .utility,
        .background
    ]
    private var currentQoSIndex = 0
    
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    // ДОБАВЛЕНО: TextView для логов
    private let logTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.backgroundColor = .black.withAlphaComponent(0.9)
        tv.textColor = .green
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.gray.cgColor
        tv.isHidden = true
        return tv
    }()
    
    private let showLogsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Показать логи", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        
        if !photos.isEmpty {
            startProcessing()
        }
    }
    
    private func addLog(_ message: String) {
        print("📋 LOG: \(message)")
        
        NSLog("📋 %@", message)
        
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(),
                                                         dateStyle: .none,
                                                         timeStyle: .medium)
            let logEntry = "[\(timestamp)] \(message)\n"
            
            self.logTextView.text = logEntry + (self.logTextView.text ?? "")
            
            self.logTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
    }
    
    // MARK: - File: processing launcher
    private func startProcessing() {
        addLog("Photos count = \(photos.count)")
        
        sourceImages = photos.compactMap {
            if let img = UIImage(named: $0) {
                return img
            } else {
                addLog("IMAGE NOT FOUND: \($0)")
                return nil
            }
        }
        
        addLog("Loaded source images: \(sourceImages.count)")
        
        guard !sourceImages.isEmpty else {
            addLog("Нет изображений — нечего обрабатывать")
            return
        }
        
        startNextQoSTest()
    }
    
    // MARK: - Sequential QoS testing
    private func startNextQoSTest() {
        guard currentQoSIndex < qosLevels.count else {
            addLog("✅ Все QoS протестированы")
            updateStatus("Все QoS протестированы")
            return
        }
        
        let qos = qosLevels[currentQoSIndex]
        let qosName = qosDescription(qos)
        
        addLog("🚀 Начинаем тест QoS: \(qosName)")
        updateStatus("Тестируем QoS: \(qosName)\nОжидайте...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.processImagesWithQoS(qos)
        }
    }
    
    private func qosDescription(_ qos: QualityOfService) -> String {
        switch qos {
        case .userInteractive: return "User Interactive"
        case .userInitiated: return "User Initiated"
        case .utility: return "Utility"
        case .background: return "Background"
        default: return "Default"
        }
    }
    
    // MARK: - Actual processing
    private func processImagesWithQoS(_ qos: QualityOfService) {
        let processor = ImageProcessor()
        let start = CFAbsoluteTimeGetCurrent()
        let qosName = qosDescription(qos)
        
        addLog("=== Начало обработки с QoS: \(qosName) ===")
        addLog("Фильтр: Chrome")
        addLog("Изображений: \(sourceImages.count)")
        
        processor.processImagesOnThread(
            sourceImages: sourceImages,
            filter: .chrome,
            qos: qos
        ) { [weak self] processedCGImages in
            
            guard let self else { return }
            
            let end = CFAbsoluteTimeGetCurrent()
            let duration = end - start
            
            let uiImages = processedCGImages.compactMap { cg -> UIImage? in
                guard let cg else { return nil }
                return UIImage(cgImage: cg)
            }
            
            DispatchQueue.main.async {
                self.processedImages = uiImages
                self.collectionView.reloadData()
                
                let imageCount = uiImages.count
                
                self.addLog("Обработка \(qosName) завершена")
                self.addLog("Время: \(String(format: "%.3f", duration)) секунд")
                self.addLog("Изображений: \(imageCount)")
                self.addLog("Успешно: \(imageCount)/\(self.sourceImages.count)")
                
                // Обновляем статус
                self.updateStatus("""
                QoS: \(qosName)
                Время: \(String(format: "%.3f", duration)) сек
                Изображений: \(imageCount)
                """)
                
                self.currentQoSIndex += 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.startNextQoSTest()
                }
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Статус лейбл
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(showLogsButton)
        showLogsButton.translatesAutoresizingMaskIntoConstraints = false
        showLogsButton.addTarget(self, action: #selector(toggleLogs), for: .touchUpInside)
        
        view.addSubview(logTextView)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Коллекция
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Кнопка логов
            showLogsButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            showLogsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            showLogsButton.widthAnchor.constraint(equalToConstant: 120),
            showLogsButton.heightAnchor.constraint(equalToConstant: 36),
            
            // TextView логов
            logTextView.topAnchor.constraint(equalTo: showLogsButton.bottomAnchor, constant: 8),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logTextView.heightAnchor.constraint(equalToConstant: 150),
            
            // Коллекция
            collectionView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(PhotosCollectionViewCell.self,
                                forCellWithReuseIdentifier: "photoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Начальное сообщение
        logTextView.text = "Логи начнут появляться здесь...\n"
    }
    
    @objc private func toggleLogs() {
        UIView.animate(withDuration: 0.3) {
            self.logTextView.isHidden = !self.logTextView.isHidden
            self.showLogsButton.setTitle(
                self.logTextView.isHidden ? "Показать логи" : "Скрыть логи",
                for: .normal
            )
        }
    }
    
    private func updateStatus(_ text: String) {
        statusLabel.text = text
        addLog("Статус: \(text)")
    }
}

// MARK: - Data Source
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        processedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photoCell",
            for: indexPath
        ) as! PhotosCollectionViewCell
        
        cell.configure(with: processedImages[indexPath.item])
        return cell
    }
}

// MARK: - Layout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 8
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow - 1)
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        
        return CGSize(width: width, height: width)
    }
}
