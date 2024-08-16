//
//  CoreDataManager.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation
import CoreData

/// A singleton class that manages the Core Data for the application.
/// The `CoreDataManager` class provides instance for accessing and managing
/// Core Data's persistent container, context, saving operations and other methods.
///
class CoreDataManager {
    ///The  singleton instance of CoreDataManager
    static let shared = CoreDataManager()
    
    /// This property holds the `NSPersistentContainer` instance which is responsible for loading
    /// and managing the Core Data model.
    let persistentContainer: NSPersistentContainer
    
    /// Initializes the `CoreDataManager` with the Core Data model container.
    ///
    /// This initializer creates a new `NSPersistentContainer` with the name `"BooksModel"`,
    /// and loads the persistent stores. If loading the persistent stores fails, the application
    /// will terminate with a fatal error.
    private init() {
        persistentContainer = NSPersistentContainer(name: "BooksModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    /// The context for performing Core Data operations.
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// A preview instance of `CoreDataManager` for testing purposes and for swiftui previews
    static var preview: CoreDataManager = {
        let manager = CoreDataManager.shared
        return manager
    }()
    
    /// Deletes all books from the Core Data store.
    func deleteAllBooks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BookEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all books: \(error)")
        }
    }
}
