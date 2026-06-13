import Foundation
import CoreData

extension FavoritePostEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePostEntity> {
        return NSFetchRequest<FavoritePostEntity>(entityName: "FavoritePostEntity")
    }
}
