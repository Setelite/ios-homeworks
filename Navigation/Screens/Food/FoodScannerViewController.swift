import UIKit
import AVFoundation

final class FoodScannerViewController: UIViewController {
    private let viewModel: FoodScannerViewModel

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let previewContainer = UIView()
    private let cameraOverlayLabel = UILabel()
    private let barcodeField = UITextField()
    private let scanButton = UIButton(type: .system)
    private let addToDiaryButton = UIButton(type: .system)

    private let productCardView = FoodProductCardView()
    private let summaryLabel = UILabel()
    private let diaryTableView = UITableView(frame: .zero, style: .plain)

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentProduct: FoodProduct?
    private var diaryEntries: [FoodDiaryEntry] = []

    init(viewModel: FoodScannerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("food.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary

        setupUI()
        bindViewModel()
        viewModel.loadTodaySummary()
        configureCameraSessionIfPossible()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewContainer.bounds
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.backgroundColor = .black
        previewContainer.layer.cornerRadius = 14
        previewContainer.clipsToBounds = true
        previewContainer.heightAnchor.constraint(equalToConstant: 220).isActive = true

        cameraOverlayLabel.text = L10n.tr("food.camera.hint")
        cameraOverlayLabel.textColor = .white
        cameraOverlayLabel.font = StyleGuide.Fonts.caption(14, weight: .medium)
        cameraOverlayLabel.translatesAutoresizingMaskIntoConstraints = false

        barcodeField.borderStyle = .roundedRect
        barcodeField.placeholder = L10n.tr("food.barcode.placeholder")
        barcodeField.keyboardType = .numberPad
        barcodeField.translatesAutoresizingMaskIntoConstraints = false

        scanButton.setTitle(L10n.tr("food.barcode.search"), for: .normal)
        scanButton.backgroundColor = StyleGuide.Colors.accent
        scanButton.tintColor = .white
        scanButton.titleLabel?.font = StyleGuide.Fonts.body(15, weight: .semibold)
        scanButton.layer.cornerRadius = 10
        scanButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        scanButton.addTarget(self, action: #selector(searchByBarcode), for: .touchUpInside)

        addToDiaryButton.setTitle(L10n.tr("food.diary.add"), for: .normal)
        addToDiaryButton.backgroundColor = StyleGuide.Colors.success
        addToDiaryButton.tintColor = .white
        addToDiaryButton.titleLabel?.font = StyleGuide.Fonts.body(15, weight: .semibold)
        addToDiaryButton.layer.cornerRadius = 10
        addToDiaryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        addToDiaryButton.isEnabled = false
        addToDiaryButton.alpha = 0.55
        addToDiaryButton.addTarget(self, action: #selector(addCurrentProductToDiary), for: .touchUpInside)

        summaryLabel.font = StyleGuide.Fonts.body(14, weight: .medium)
        summaryLabel.textColor = StyleGuide.Colors.textSecondary
        summaryLabel.numberOfLines = 0

        diaryTableView.translatesAutoresizingMaskIntoConstraints = false
        diaryTableView.dataSource = self
        diaryTableView.isScrollEnabled = false
        diaryTableView.backgroundColor = .clear
        diaryTableView.separatorStyle = .singleLine
        diaryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "diaryCell")

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(previewContainer)
        contentStack.addArrangedSubview(barcodeField)

        let buttons = UIStackView(arrangedSubviews: [scanButton, addToDiaryButton])
        buttons.axis = .horizontal
        buttons.spacing = 10
        buttons.distribution = .fillEqually
        contentStack.addArrangedSubview(buttons)

        contentStack.addArrangedSubview(productCardView)
        contentStack.addArrangedSubview(summaryLabel)
        contentStack.addArrangedSubview(diaryTableView)

        previewContainer.addSubview(cameraOverlayLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),

            cameraOverlayLabel.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor),
            cameraOverlayLabel.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -12),

            diaryTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }

        viewModel.onDailyEntriesChange = { [weak self] entries, summary in
            self?.diaryEntries = entries
            self?.summaryLabel.text = L10n.format(
                "food.diary.summary",
                summary.calories,
                summary.proteins,
                summary.fats,
                summary.carbs
            )
            self?.diaryTableView.reloadData()
        }
    }

    private func render(_ state: FoodScannerViewModel.State) {
        switch state {
        case .idle:
            break

        case .loading:
            cameraOverlayLabel.text = L10n.tr("food.state.loading")

        case .loaded(let product):
            currentProduct = product
            productCardView.configure(with: product)
            addToDiaryButton.isEnabled = true
            addToDiaryButton.alpha = 1
            cameraOverlayLabel.text = L10n.tr("food.camera.hint")

        case .error(let message):
            cameraOverlayLabel.text = L10n.tr("food.camera.hint")
            let alert = UIAlertController(title: L10n.tr("common.error"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.tr("common.ok"), style: .default))
            present(alert, animated: true)
        }
    }

    private func configureCameraSessionIfPossible() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCaptureSession()
                    } else {
                        self?.cameraOverlayLabel.text = L10n.tr("food.camera.denied")
                    }
                }
            }
        default:
            cameraOverlayLabel.text = L10n.tr("food.camera.denied")
        }
    }

    private func setupCaptureSession() {
        guard previewLayer == nil else { return }
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            cameraOverlayLabel.text = L10n.tr("food.camera.unavailable")
            return
        }

        let output = AVCaptureMetadataOutput()

        guard captureSession.canAddInput(input), captureSession.canAddOutput(output) else {
            cameraOverlayLabel.text = L10n.tr("food.camera.unavailable")
            return
        }

        captureSession.addInput(input)
        captureSession.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.ean8, .ean13, .upce]

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @objc private func searchByBarcode() {
        guard let barcode = barcodeField.text, !barcode.isEmpty else { return }
        Task { [weak self] in
            await self?.viewModel.fetchProduct(barcode: barcode)
        }
    }

    @objc private func addCurrentProductToDiary() {
        guard let product = currentProduct else { return }
        viewModel.addToDiary(product)
    }
}

extension FoodScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else { return }

        barcodeField.text = barcode
        Task { [weak self] in
            await self?.viewModel.fetchProduct(barcode: barcode)
        }
    }
}

extension FoodScannerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaryEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "diaryCell", for: indexPath)
        let entry = diaryEntries[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = entry.name
        content.secondaryText = L10n.format(
            "food.diary.entry",
            entry.nutrients.calories,
            entry.nutrients.proteins,
            entry.nutrients.fats,
            entry.nutrients.carbs
        )
        content.secondaryTextProperties.color = StyleGuide.Colors.textSecondary
        content.textProperties.color = StyleGuide.Colors.textPrimary
        cell.contentConfiguration = content
        cell.backgroundColor = .clear

        return cell
    }
}
