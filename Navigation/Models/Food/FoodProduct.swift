import Foundation

struct FoodProduct: Equatable {
    let barcode: String
    let name: String
    let nutrients: Nutrients
    let ingredients: String
    let allergens: [Allergen]
}

struct Nutrients: Equatable {
    let calories: Double
    let proteins: Double
    let fats: Double
    let carbs: Double
}

struct Allergen: Equatable, Hashable {
    let name: String
}

struct FoodDiaryEntry: Equatable {
    let id: UUID
    let date: Date
    let barcode: String
    let name: String
    let nutrients: Nutrients
}

struct DailyNutritionSummary: Equatable {
    let calories: Double
    let proteins: Double
    let fats: Double
    let carbs: Double

    static let zero = DailyNutritionSummary(calories: 0, proteins: 0, fats: 0, carbs: 0)
}
