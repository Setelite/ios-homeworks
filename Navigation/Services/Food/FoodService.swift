import Foundation

protocol FoodServiceProtocol {
    func fetchProduct(by barcode: String) async throws -> FoodProduct
}

final class FoodService: FoodServiceProtocol {
    private struct OFFResponse: Decodable {
        let status: Int
        let product: OFFProduct?
    }

    private struct OFFProduct: Decodable {
        let productName: String?
        let nutriments: OFFNutriments?
        let ingredientsText: String?
        let allergensTags: [String]?

        enum CodingKeys: String, CodingKey {
            case productName = "product_name"
            case nutriments
            case ingredientsText = "ingredients_text"
            case allergensTags = "allergens_tags"
        }
    }

    private struct OFFNutriments: Decodable {
        let energyKcal100g: Double?
        let proteins100g: Double?
        let fat100g: Double?
        let carbohydrates100g: Double?

        enum CodingKeys: String, CodingKey {
            case energyKcal100g = "energy-kcal_100g"
            case proteins100g = "proteins_100g"
            case fat100g = "fat_100g"
            case carbohydrates100g = "carbohydrates_100g"
        }
    }

    private let session: URLSession

    init(session: URLSession = FoodService.makeSession()) {
        self.session = session
    }

    func fetchProduct(by barcode: String) async throws -> FoodProduct {
        let sanitizedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedBarcode.isEmpty else { throw APIError.notFound }

        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(sanitizedBarcode).json") else {
            throw APIError.badURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network
        }

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw APIError.invalidResponse
        }

        let payload: OFFResponse
        do {
            payload = try JSONDecoder().decode(OFFResponse.self, from: data)
        } catch {
            throw APIError.decoding
        }

        guard payload.status == 1, let product = payload.product else {
            throw APIError.notFound
        }

        return FoodProduct(
            barcode: sanitizedBarcode,
            name: product.productName?.nonEmpty ?? L10n.tr("food.unknown_product"),
            nutrients: Nutrients(
                calories: product.nutriments?.energyKcal100g ?? 0,
                proteins: product.nutriments?.proteins100g ?? 0,
                fats: product.nutriments?.fat100g ?? 0,
                carbs: product.nutriments?.carbohydrates100g ?? 0
            ),
            ingredients: product.ingredientsText?.nonEmpty ?? L10n.tr("food.ingredients.empty"),
            allergens: mapAllergens(product.allergensTags)
        )
    }

    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 25 * 1024 * 1024,
            diskCapacity: 75 * 1024 * 1024,
            diskPath: "food-service-cache"
        )
        return URLSession(configuration: config)
    }

    private func mapAllergens(_ tags: [String]?) -> [Allergen] {
        let names = (tags ?? [])
            .map { $0.replacingOccurrences(of: "en:", with: "") }
            .map { $0.replacingOccurrences(of: "-", with: " ") }
            .map { $0.capitalized }

        if names.isEmpty {
            return [Allergen(name: L10n.tr("food.allergens.none"))]
        }

        return names.map(Allergen.init(name:))
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
