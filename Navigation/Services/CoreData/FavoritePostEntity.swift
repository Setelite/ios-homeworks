import Foundation
import CoreData

@objc(FavoritePostEntity)
public class FavoritePostEntity: NSManagedObject {
    @NSManaged public var author: String?
    @NSManaged public var text: String?
    @NSManaged public var likes: Int64
    @NSManaged public var views: Int64
    @NSManaged public var image: String?
}
