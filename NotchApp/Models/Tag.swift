import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var notches: Set<Notch>?
}

extension Tag {
    convenience init(context: NSManagedObjectContext, name: String, colorHex: String? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
}
