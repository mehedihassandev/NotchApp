import Foundation
import CoreData

@objc(Attachment)
public class Attachment: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var notch: Notch?
}

extension Attachment {
    convenience init(context: NSManagedObjectContext, type: String, url: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Attachment", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.type = type
        self.url = url
    }
}
