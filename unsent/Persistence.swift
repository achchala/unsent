//
//  Persistence.swift
//  unsent
//
//  Created by Achchala Deepan on 2025-08-12.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleMessages = [
            ("I miss you more than words can express", "general", "John"),
            ("I'm sorry for everything I said", "apology", "Mom"),
            ("Thank you for always being there", "thankYou", "Best Friend"),
            ("I love you with all my heart", "loveLetter", "Sarah"),
            ("Goodbye, I hope you find happiness", "goodbye", "Ex")
        ]
        
        for (content, category, recipient) in sampleMessages {
            let newMessage = Message(context: viewContext)
            newMessage.id = UUID()
            newMessage.content = content
            newMessage.category = category
            newMessage.recipient = recipient
            newMessage.isPrivate = true
            newMessage.timestamp = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "unsent")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Core Data Helper Methods
extension PersistenceController {
    
    /// Save the context if there are changes
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Create a new message
    func createMessage(content: String, category: String, isPrivate: Bool, recipient: String?) {
        let context = container.viewContext
        let message = Message(context: context)
        
        message.id = UUID()
        message.content = content
        message.category = category
        message.isPrivate = isPrivate
        message.recipient = recipient
        message.timestamp = Date()
        
        save()
    }
    
    /// Delete a message
    func deleteMessage(_ message: Message) {
        let context = container.viewContext
        context.delete(message)
        save()
    }
    
    /// Fetch messages with optional filtering
    func fetchMessages(category: String? = nil, isPrivate: Bool? = nil) -> [Message] {
        let context = container.viewContext
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if let isPrivate = isPrivate {
            predicates.append(NSPredicate(format: "isPrivate == %@", NSNumber(value: isPrivate)))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Sort by timestamp, newest first
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    /// Search messages by content or recipient
    func searchMessages(searchText: String) -> [Message] {
        let context = container.viewContext
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        
        let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
        let recipientPredicate = NSPredicate(format: "recipient CONTAINS[cd] %@", searchText)
        let categoryPredicate = NSPredicate(format: "category CONTAINS[cd] %@", searchText)
        
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            contentPredicate,
            recipientPredicate,
            categoryPredicate
        ])
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error searching messages: \(error)")
            return []
        }
    }
}
