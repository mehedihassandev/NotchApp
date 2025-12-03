import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Use NSPersistentContainer instead of CloudKit version for local storage
        container = NSPersistentContainer(name: "NotchApp")

        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        } else {
            // Keep persistent history tracking enabled to avoid read-only mode
            if let desc = container.persistentStoreDescriptions.first {
                desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }
        }
        // Note: CloudKit sync disabled. To enable:
        // 1. Change to NSPersistentCloudKitContainer
        // 2. Set up proper iCloud container identifier in Xcode
        // 3. Configure CloudKit container options

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Log the error instead of crashing
                print("⚠️ Core Data error: \(error), \(error.userInfo)")

                // Common issues:
                // 1. CloudKit container identifier mismatch
                // 2. Model incompatibility - may need migration
                // 3. iCloud not configured

                #if DEBUG
                print("Store Description: \(storeDescription)")
                #endif

                // For development, we'll handle this gracefully
                // In production, you might want to show an alert to the user
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
