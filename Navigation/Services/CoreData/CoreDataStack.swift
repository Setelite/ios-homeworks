//
//  CoreDataStack.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Navigation")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData error: \(error)")
            }
        }
        return container
    }()

    // MARK: - ViewContext (только для чтения)
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - BackgroundContext (для записи)
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
