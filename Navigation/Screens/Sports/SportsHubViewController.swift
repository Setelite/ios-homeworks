import UIKit
import MapKit
import CoreLocation

final class SportsHubViewController: UIViewController {
    private enum SportsFilter: Int, CaseIterable {
        case all
        case running
        case cycling
        case yoga

        var title: String {
            switch self {
            case .all: return L10n.tr("sports.filter.sport.all")
            case .running: return L10n.tr("sports.filter.sport.running")
            case .cycling: return L10n.tr("sports.filter.sport.cycling")
            case .yoga: return L10n.tr("sports.filter.sport.yoga")
            }
        }

        func matches(_ sport: String) -> Bool {
            let lower = sport.lowercased()
            switch self {
            case .all: return true
            case .running: return lower.contains("бег") || lower.contains("run")
            case .cycling: return lower.contains("вело") || lower.contains("cycl")
            case .yoga: return lower.contains("йога") || lower.contains("yoga")
            }
        }
    }

    private enum RadiusFilter: Int, CaseIterable {
        case oneKm
        case fiveKm
        case fifteenKm

        var title: String {
            switch self {
            case .oneKm: return L10n.tr("sports.filter.radius.1")
            case .fiveKm: return L10n.tr("sports.filter.radius.5")
            case .fifteenKm: return L10n.tr("sports.filter.radius.15")
            }
        }

        var kilometers: Double {
            switch self {
            case .oneKm: return 1
            case .fiveKm: return 5
            case .fifteenKm: return 15
            }
        }
    }

    private let viewModel: SportsHubViewModel
    private let nearbyService: NearbyAthletesServiceProtocol
    private let firebaseNearbyService: FirebaseNearbyAthletesServiceProtocol
    private let locationManager = CLLocationManager()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let stateView = ScreenStateView()

    private let mapView = MKMapView()
    private let nearbyStack = UIStackView()
    private let challengesStack = UIStackView()
    private let leaderboardStack = UIStackView()
    private let sportFilterControl = UISegmentedControl()
    private let radiusFilterControl = UISegmentedControl()

    private var userCoordinate: CLLocationCoordinate2D?
    private var loadTask: Task<Void, Never>?
    private var allAthletes: [NearbyAthlete] = []

    init(
        viewModel: SportsHubViewModel = SportsHubViewModel(),
        nearbyService: NearbyAthletesServiceProtocol = NearbyAthletesService(),
        firebaseNearbyService: FirebaseNearbyAthletesServiceProtocol = FirebaseNearbyAthletesService()
    ) {
        self.viewModel = viewModel
        self.nearbyService = nearbyService
        self.firebaseNearbyService = firebaseNearbyService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("sports.title")
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        configureLocation()
        configureUI()
        loadContent()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadTask?.cancel()
    }

    private func configureLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 25
        locationManager.pausesLocationUpdatesAutomatically = true

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            if let current = locationManager.location?.coordinate {
                userCoordinate = current
            }
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        default:
            break
        }
    }

    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(reloadTapped)
        )

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        setupStateView()
        setupSections()
    }

    private func setupStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.onRetry = { [weak self] in
            self?.loadContent()
        }
        view.addSubview(stateView)

        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSections() {
        let subtitleLabel = makeSubtitleLabel(L10n.tr("sports.subtitle"))
        contentStack.addArrangedSubview(subtitleLabel)

        contentStack.addArrangedSubview(makeSectionTitle(L10n.tr("sports.section.map")))
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 16
        mapView.layer.masksToBounds = true
        mapView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        mapView.delegate = self
        contentStack.addArrangedSubview(mapView)

        contentStack.addArrangedSubview(makeSectionTitle(L10n.tr("sports.section.nearby")))
        setupFilterControls()
        nearbyStack.axis = .vertical
        nearbyStack.spacing = 10
        contentStack.addArrangedSubview(nearbyStack)

        contentStack.addArrangedSubview(makeSectionTitle(L10n.tr("sports.section.challenges")))
        challengesStack.axis = .vertical
        challengesStack.spacing = 10
        contentStack.addArrangedSubview(challengesStack)

        contentStack.addArrangedSubview(makeSectionTitle(L10n.tr("sports.section.leaderboard")))
        leaderboardStack.axis = .vertical
        leaderboardStack.spacing = 8
        contentStack.addArrangedSubview(leaderboardStack)
    }

    private func setupFilterControls() {
        sportFilterControl.removeAllSegments()
        SportsFilter.allCases.enumerated().forEach { index, filter in
            sportFilterControl.insertSegment(withTitle: filter.title, at: index, animated: false)
        }
        sportFilterControl.selectedSegmentIndex = 0
        sportFilterControl.addTarget(self, action: #selector(filtersChanged), for: .valueChanged)

        radiusFilterControl.removeAllSegments()
        RadiusFilter.allCases.enumerated().forEach { index, filter in
            radiusFilterControl.insertSegment(withTitle: filter.title, at: index, animated: false)
        }
        radiusFilterControl.selectedSegmentIndex = 2
        radiusFilterControl.addTarget(self, action: #selector(filtersChanged), for: .valueChanged)

        let filtersStack = UIStackView(arrangedSubviews: [sportFilterControl, radiusFilterControl])
        filtersStack.axis = .vertical
        filtersStack.spacing = 10
        contentStack.addArrangedSubview(filtersStack)
    }

    private var selectedSportsFilter: SportsFilter {
        SportsFilter(rawValue: sportFilterControl.selectedSegmentIndex) ?? .all
    }

    private var selectedRadiusFilter: RadiusFilter {
        RadiusFilter(rawValue: radiusFilterControl.selectedSegmentIndex) ?? .fifteenKm
    }

    private func loadContent() {
        loadTask?.cancel()
        stateView.apply(.loading(L10n.tr("sports.state.loading")) )
        if userCoordinate == nil,
           locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }

        loadTask = Task { [weak self] in
            guard let self else { return }

            let coordinate = self.userCoordinate ?? self.viewModel.defaultCenterCoordinate
            self.viewModel.applyUserCoordinate(coordinate)

            let athletes = await self.fetchAthletes(around: coordinate)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.allAthletes = athletes
                self.viewModel.applyNearbyAthletes(self.filteredAthletes(from: athletes))
                self.renderMap()
                self.renderNearby()
                self.renderChallenges()
                self.renderLeaderboard()
                self.stateView.apply(.content)
            }
        }
    }

    private func fetchAthletes(around coordinate: CLLocationCoordinate2D) async -> [NearbyAthlete] {
        if let user = FirebaseSessionStorage.shared.user,
           let token = FirebaseSessionStorage.shared.token,
           !token.isEmpty,
           let backendAthletes = try? await firebaseNearbyService.syncAndFetchNearby(
            user: user,
            token: token,
            coordinate: coordinate,
            radiusKm: selectedRadiusFilter.kilometers,
            limit: 16
           ),
           !backendAthletes.isEmpty {
            return backendAthletes
        }

        if let apiAthletes = try? await nearbyService.fetchNearbyAthletes(around: coordinate, limit: 16),
           !apiAthletes.isEmpty {
            return apiAthletes
        }

        return viewModel.fallbackAthletes(around: coordinate)
    }

    private func filteredAthletes(from athletes: [NearbyAthlete]) -> [NearbyAthlete] {
        athletes.filter {
            $0.distanceKm <= selectedRadiusFilter.kilometers &&
            selectedSportsFilter.matches($0.sport)
        }
    }

    private func renderMap() {
        mapView.removeOverlays(mapView.overlays)

        let removableAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(removableAnnotations)

        mapView.setRegion(viewModel.mapRegion, animated: false)

        let route = MKPolyline(coordinates: viewModel.routeCoordinates, count: viewModel.routeCoordinates.count)
        mapView.addOverlay(route)

        let annotations = viewModel.nearbyAthletes.map { athlete -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = athlete.name
            annotation.subtitle = athlete.sport
            annotation.coordinate = athlete.coordinate
            return annotation
        }

        mapView.addAnnotations(annotations)
    }

    private func renderNearby() {
        clearArrangedSubviews(in: nearbyStack)

        if viewModel.nearbyAthletes.isEmpty {
            nearbyStack.addArrangedSubview(makeCardSubtitle(L10n.tr("sports.nearby.empty")))
            return
        }

        viewModel.nearbyAthletes.forEach { athlete in
            let card = makeCardContainer()
            let title = makeCardTitle("\(athlete.name) • \(athlete.sport)")
            let subtitle = makeCardSubtitle("\(athlete.status) • \(String(format: L10n.tr("sports.nearby.distance"), athlete.distanceKm))")

            let stack = UIStackView(arrangedSubviews: [title, subtitle])
            stack.axis = .vertical
            stack.spacing = 6
            card.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])
            nearbyStack.addArrangedSubview(card)
        }
    }

    private func renderChallenges() {
        clearArrangedSubviews(in: challengesStack)

        viewModel.challenges.forEach { challenge in
            let card = makeCardContainer()
            let title = makeCardTitle(challenge.title)
            let meta = makeCardSubtitle("\(challenge.progressText) • \(L10n.format("sports.challenge.participants", challenge.participants))")
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progressTintColor = StyleGuide.Colors.accent
            progress.trackTintColor = StyleGuide.Colors.border
            progress.progress = challenge.progress

            let stack = UIStackView(arrangedSubviews: [title, meta, progress])
            stack.axis = .vertical
            stack.spacing = 8
            card.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])

            challengesStack.addArrangedSubview(card)
        }
    }

    private func renderLeaderboard() {
        clearArrangedSubviews(in: leaderboardStack)

        for (index, entry) in viewModel.leaderboard.enumerated() {
            let row = UIView()
            row.backgroundColor = StyleGuide.Colors.card
            row.layer.cornerRadius = 12

            let place = UILabel()
            place.font = StyleGuide.Fonts.body(15, weight: .semibold)
            place.textColor = StyleGuide.Colors.textSecondary
            place.text = "#\(index + 1)"

            let name = UILabel()
            name.font = StyleGuide.Fonts.body(15, weight: .semibold)
            name.textColor = StyleGuide.Colors.textPrimary
            name.text = entry.name

            let points = UILabel()
            points.font = StyleGuide.Fonts.caption(13, weight: .medium)
            points.textColor = StyleGuide.Colors.textSecondary
            points.textAlignment = .right
            points.numberOfLines = 2
            points.text = "\(L10n.format("sports.leaderboard.points", entry.points))\n\(L10n.format("sports.leaderboard.streak", entry.streakDays))"

            let stack = UIStackView(arrangedSubviews: [place, name, points])
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 10
            row.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
                stack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
                stack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -10),
                place.widthAnchor.constraint(equalToConstant: 32),
                points.widthAnchor.constraint(equalToConstant: 92)
            ])

            leaderboardStack.addArrangedSubview(row)
        }
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(18, weight: .bold)
        label.textColor = StyleGuide.Colors.textPrimary
        label.text = text
        return label
    }

    private func makeSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(14, weight: .regular)
        label.textColor = StyleGuide.Colors.textSecondary
        label.numberOfLines = 0
        label.text = text
        return label
    }

    private func makeCardContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = StyleGuide.Colors.card
        view.layer.cornerRadius = 14
        view.layer.borderColor = StyleGuide.Colors.border.cgColor
        view.layer.borderWidth = 1
        return view
    }

    private func makeCardTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(15, weight: .semibold)
        label.textColor = StyleGuide.Colors.textPrimary
        label.numberOfLines = 2
        label.text = text
        return label
    }

    private func makeCardSubtitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = StyleGuide.Fonts.caption(13, weight: .regular)
        label.textColor = StyleGuide.Colors.textSecondary
        label.numberOfLines = 0
        label.text = text
        return label
    }

    private func clearArrangedSubviews(in stack: UIStackView) {
        stack.arrangedSubviews.forEach { subview in
            stack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    @objc private func reloadTapped() {
        loadContent()
    }

    @objc private func filtersChanged() {
        viewModel.applyNearbyAthletes(filteredAthletes(from: allAthletes))
        renderMap()
        renderNearby()
    }
}

extension SportsHubViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }

        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = StyleGuide.Colors.accent
        renderer.lineWidth = 4
        renderer.alpha = 0.9
        return renderer
    }
}

extension SportsHubViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            if let current = manager.location?.coordinate {
                userCoordinate = current
            }
            manager.startUpdatingLocation()
            manager.requestLocation()
        case .denied, .restricted:
            mapView.showsUserLocation = false
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Берем самую свежую и валидную точку, чтобы показывать реальную геопозицию пользователя.
        guard let last = locations
            .filter({ $0.horizontalAccuracy > 0 && $0.horizontalAccuracy < 1000 })
            .sorted(by: { $0.timestamp > $1.timestamp })
            .first else { return }

        let newCoordinate = last.coordinate
        let shouldReload: Bool
        if let previous = userCoordinate {
            let prevLocation = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            shouldReload = prevLocation.distance(from: last) > 25
        } else {
            shouldReload = true
        }
        userCoordinate = newCoordinate

        if shouldReload {
            loadContent()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if userCoordinate == nil {
            loadContent()
        }
    }
}
