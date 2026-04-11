import Foundation
import CoreData

protocol NutritionDiaryRepositoryProtocol {
    func save(_ product: FoodProduct, at date: Date) throws
    func entries(for date: Date) throws -> [FoodDiaryEntry]
}

final class CoreDataNutritionDiaryRepository: NutritionDiaryRepositoryProtocol {
    private enum Constants {
        static let entityName = "NutritionDiaryEntryEntity"
    }

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func save(_ product: FoodProduct, at date: Date) throws {
        let context = coreDataStack.viewContext
        let object = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context)
        object.setValue(UUID(), forKey: "id")
        object.setValue(date, forKey: "date")
        object.setValue(product.barcode, forKey: "barcode")
        object.setValue(product.name, forKey: "name")
        object.setValue(product.nutrients.calories, forKey: "calories")
        object.setValue(product.nutrients.proteins, forKey: "proteins")
        object.setValue(product.nutrients.fats, forKey: "fats")
        object.setValue(product.nutrients.carbs, forKey: "carbs")

        try context.save()
    }

    func entries(for date: Date) throws -> [FoodDiaryEntry] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) else {
            return []
        }

        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfDay as NSDate, endOfDay as NSDate)

        return try coreDataStack.viewContext.fetch(request).compactMap { object in
            guard
                let id = object.value(forKey: "id") as? UUID,
                let entryDate = object.value(forKey: "date") as? Date,
                let barcode = object.value(forKey: "barcode") as? String,
                let name = object.value(forKey: "name") as? String
            else {
                return nil
            }

            return FoodDiaryEntry(
                id: id,
                date: entryDate,
                barcode: barcode,
                name: name,
                nutrients: Nutrients(
                    calories: object.value(forKey: "calories") as? Double ?? 0,
                    proteins: object.value(forKey: "proteins") as? Double ?? 0,
                    fats: object.value(forKey: "fats") as? Double ?? 0,
                    carbs: object.value(forKey: "carbs") as? Double ?? 0
                )
            )
        }
    }
}
