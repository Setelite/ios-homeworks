import XCTest
@testable import Navigation

@MainActor
final class FoodScannerViewModelTests: XCTestCase {
    private final class FoodServiceMock: FoodServiceProtocol {
        var product: FoodProduct?

        func fetchProduct(by barcode: String) async throws -> FoodProduct {
            guard let product else { throw APIError.notFound }
            return product
        }
    }

    private final class DiaryRepositoryMock: NutritionDiaryRepositoryProtocol {
        var storage: [FoodDiaryEntry] = []

        func save(_ product: FoodProduct, at date: Date) throws {
            storage.append(
                FoodDiaryEntry(
                    id: UUID(),
                    date: date,
                    barcode: product.barcode,
                    name: product.name,
                    nutrients: product.nutrients
                )
            )
        }

        func entries(for date: Date) throws -> [FoodDiaryEntry] {
            storage
        }
    }

    func testAddToDiary_updatesSummary() {
        let service = FoodServiceMock()
        let diary = DiaryRepositoryMock()
        let viewModel = FoodScannerViewModel(foodService: service, diaryRepository: diary)

        let summaryExpectation = expectation(description: "summary")
        viewModel.onDailyEntriesChange = { entries, summary in
            guard !entries.isEmpty else { return }
            XCTAssertEqual(entries.count, 1)
            XCTAssertEqual(summary.calories, 250)
            XCTAssertEqual(summary.proteins, 12)
            XCTAssertEqual(summary.fats, 5)
            XCTAssertEqual(summary.carbs, 30)
            summaryExpectation.fulfill()
        }

        viewModel.addToDiary(
            FoodProduct(
                barcode: "460123",
                name: "Protein Bar",
                nutrients: Nutrients(calories: 250, proteins: 12, fats: 5, carbs: 30),
                ingredients: "Milk",
                allergens: [Allergen(name: "Milk")]
            )
        )

        waitForExpectations(timeout: 1)
    }
}
