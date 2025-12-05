import CoreData
import Foundation

// MARK: - Persistence Controller
/// Core Data stack management for local data persistence
/// Handles store loading, configuration, and context management

struct PersistenceController {

    // MARK: - Singleton
    static let shared = PersistenceController()

    // MARK: - Preview Support
    /// In-memory store for SwiftUI previews
    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    // MARK: - Properties
    let container: NSPersistentContainer

    /// Main view context for UI operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Initialization

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NotchApp")

        configureContainer(inMemory: inMemory)
        loadPersistentStores()
        configureViewContext()
    }

    // MARK: - Configuration

    private func configureContainer(inMemory: Bool) {
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        } else {
            configureProductionStore()
        }
    }

    private func configureProductionStore() {
        guard let description = container.persistentStoreDescriptions.first else { return }

        // Enable persistent history tracking
        description.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        // Enable remote change notifications (for future CloudKit support)
        description.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
    }

    private func loadPersistentStores() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                self.handlePersistentStoreError(error, description: storeDescription)
            } else {
                logInfo("Core Data store loaded successfully", category: .persistence)
            }
        }
    }

    private func configureViewContext() {
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Error Handling

    private func handlePersistentStoreError(_ error: NSError, description: NSPersistentStoreDescription) {
        logError("Core Data error: \(error), \(error.userInfo)", category: .persistence)

        #if DEBUG
        logDebug("Store Description: \(description)", category: .persistence)
        #endif

        // Common issues:
        // 1. CloudKit container identifier mismatch
        // 2. Model incompatibility - may need migration
        // 3. iCloud not configured
    }

    // MARK: - Public Methods

    /// Saves the view context if there are changes
    func save() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
            logDebug("Context saved successfully", category: .persistence)
        } catch {
            logError("Failed to save context: \(error)", category: .persistence)
        }
    }

    /// Creates a new background context for concurrent operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
