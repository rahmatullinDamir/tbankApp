import CoreData
import UIKit
import Foundation

protocol CoreDataManaging {
    func fetchTrips(with status: TripStatus?) -> [TripDto]
    func saveTrip(_ tripDto: TripDto)
    func clearAllData()
}

final class CoreDataManager: CoreDataManaging {
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not access AppDelegate")
        }
        return appDelegate.persistentContainer
    }()
    
    private var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    private init() {
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave(_:)),
            name: NSManagedObjectContext.didSaveObjectsNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func getContext() -> NSManagedObjectContext {
        if Thread.isMainThread {
            return mainContext
        } else {
            let context = persistentContainer.newBackgroundContext()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return context
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            block(context)
        }
    }
    
    func saveContext() {
        let context = getContext()
        guard context.hasChanges else { return }
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    @objc private func managedObjectContextDidSave(_ notification: Foundation.Notification) {
        guard let sender = notification.object as? NSManagedObjectContext else { return }

        if sender !== mainContext {
            mainContext.perform { [weak self] in
                self?.mainContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
}

extension CoreDataManager {
    func clearAllData() {
        let entities = ["Trip", "Expense", "Category", "Notification", "User"]
        let context = getContext()
        
        context.performAndWait {
            entities.forEach { entityName in
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
                } catch {
                    print("Error clearing \(entityName) data: \(error)")
                }
            }
            
            saveContext()
        }
    }
} 
