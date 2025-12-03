import Foundation
import CoreData

@objc(Notch)
public class Notch: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notch> {
        return NSFetchRequest<Notch>(entityName: "Notch")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var pinned: Bool
    @NSManaged public var tags: Set<Tag>?
    @NSManaged public var attachments: Set<Attachment>?
}

extension Notch {
    convenience init(context: NSManagedObjectContext, title: String? = nil, body: String? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "Notch", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.title = title
        self.body = body
        self.createdAt = Date()
        self.updatedAt = Date()
        self.pinned = false
    }

    var tagArray: [Tag] {
        return Array(tags ?? [])
    }

    func addTag(_ tag: Tag) {
        var set = tags ?? Set<Tag>()
        set.insert(tag)
        tags = set
    }

    func removeTag(_ tag: Tag) {
        var set = tags ?? Set<Tag>()
        set.remove(tag)
        tags = set
    }
}
