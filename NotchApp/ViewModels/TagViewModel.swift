import Foundation
import CoreData
import Combine

final class TagViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    @Published var tags: [Tag] = []

    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAll()
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { [weak self] _ in self?.fetchAll() }
            .store(in: &cancellables)
    }

    func fetchAll() {
        let req: NSFetchRequest<Tag> = Tag.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            tags = try context.fetch(req)
        } catch {
            print("Fetch tags failed:", error)
            tags = []
        }
    }

    func create(name: String, colorHex: String? = nil) -> Tag {
        let t = Tag(context: context, name: name, colorHex: colorHex)
        save()
        return t
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Save error:", error)
        }
        fetchAll()
    }
}
