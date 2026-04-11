import Foundation

final class FoodScannerViewModel {
    enum State {
        case idle
        case loading
        case loaded(FoodProduct)
        case error(String)
    }

    private let foodService: FoodServiceProtocol
    private let diaryRepository: NutritionDiaryRepositoryProtocol

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    private(set) var dailyEntries: [FoodDiaryEntry] = [] {
        didSet { onDailyEntriesChange?(dailyEntries, calculateSummary(entries: dailyEntries)) }
    }

    var onStateChange: ((State) -> Void)?
    var onDailyEntriesChange: (([FoodDiaryEntry], DailyNutritionSummary) -> Void)?

    init(
        foodService: FoodServiceProtocol,
        diaryRepository: NutritionDiaryRepositoryProtocol
    ) {
        self.foodService = foodService
        self.diaryRepository = diaryRepository
    }

    @MainActor
    func loadTodaySummary() {
        do {
            dailyEntries = try diaryRepository.entries(for: Date())
        } catch {
            state = .error(L10n.tr("food.error.diary_load"))
        }
    }

    @MainActor
    func fetchProduct(barcode: String) async {
        state = .loading

        do {
            let product = try await foodService.fetchProduct(by: barcode)
            state = .loaded(product)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? L10n.tr("api.error.network")
            state = .error(message)
        }
    }

    @MainActor
    func addToDiary(_ product: FoodProduct) {
        do {
            try diaryRepository.save(product, at: Date())
            dailyEntries = try diaryRepository.entries(for: Date())
        } catch {
            state = .error(L10n.tr("food.error.diary_save"))
        }
    }

    private func calculateSummary(entries: [FoodDiaryEntry]) -> DailyNutritionSummary {
        guard !entries.isEmpty else { return .zero }

        return DailyNutritionSummary(
            calories: entries.reduce(0) { $0 + $1.nutrients.calories },
            proteins: entries.reduce(0) { $0 + $1.nutrients.proteins },
            fats: entries.reduce(0) { $0 + $1.nutrients.fats },
            carbs: entries.reduce(0) { $0 + $1.nutrients.carbs }
        )
    }
}
