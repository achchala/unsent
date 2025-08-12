# Core Data Implementation

**Core Data** is Apple's framework for managing the model layer of my app. It provides:
- **Data persistence** - Save data to device storage
- **Object graph management** - Handle relationships between data objects
- **Query capabilities** - Search and filter data efficiently
- **Performance optimization** - Handle large datasets smoothly

## Core Data Architecture in unsent

### 1. Data Model (unsent.xcdatamodeld)

**Entity**: `Message`
```xml
<entity name="Message" representedClassName="Message" syncable="YES" codeGenerationType="class">
    <attribute name="category" optional="YES" attributeType="String" defaultValueString="general"/>
    <attribute name="content" optional="YES" attributeType="String"/>
    <attribute name="id" optional="YES" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="isPrivate" optional="YES" attributeType="Boolean" defaultValueString="YES" usesScalarValueType="YES"/>
    <attribute name="recipient" optional="YES" attributeType="String"/>
    <attribute name="timestamp" optional="YES" attributeType="Date" usesScalarValueType="NO"/>
</entity>
```

**Key Points I learned:**
- `codeGenerationType="class"` - Xcode automatically generates Swift classes
- `syncable="YES"` - Enables CloudKit sync (future feature)
- `usesScalarValueType` - Determines if property is optional or required

### 2. Persistence Controller (Persistence.swift)

**Core Data Stack Setup:**
```swift
struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "unsent")
        // ... setup code
    }
}
```

**Key Components I'm using:**
- `NSPersistentCloudKitContainer` - Manages Core Data stack with CloudKit support
- `viewContext` - Main context for UI operations
- `persistentStoreDescriptions` - Configuration for data storage

### 3. Helper Methods I Built

#### Creating Messages
```swift
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
```

#### Fetching Messages
```swift
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
    
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
    
    do {
        return try context.fetch(request)
    } catch {
        print("Error fetching messages: \(error)")
        return []
    }
}
```

#### Searching Messages
```swift
func searchMessages(searchText: String) -> [Message] {
    let request: NSFetchRequest<Message> = Message.fetchRequest()
    
    let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
    let recipientPredicate = NSPredicate(format: "recipient CONTAINS[cd] %@", searchText)
    let categoryPredicate = NSPredicate(format: "category CONTAINS[cd] %@", searchText)
    
    request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
        contentPredicate,
        recipientPredicate,
        categoryPredicate
    ])
    
    // ... fetch and return
}
```

## Core Data Concepts I Learned

### 1. Managed Object Context
- **Think of it as a "scratch pad"** for Core Data operations
- All changes happen in the context first
- Must explicitly save to persist changes
- UI operations should use the main context

### 2. Fetch Requests
- **NSFetchRequest** - How I query my data
- **NSPredicate** - Filter conditions (like WHERE in SQL)
- **NSSortDescriptor** - Sort order (like ORDER BY in SQL)

### 3. Predicates
```swift
// Simple equality
NSPredicate(format: "category == %@", "apology")

// Contains text (case-insensitive)
NSPredicate(format: "content CONTAINS[cd] %@", "love")

// Boolean comparison
NSPredicate(format: "isPrivate == %@", NSNumber(value: true))

// Date comparison
NSPredicate(format: "timestamp > %@", someDate as NSDate)

// Complex predicates
let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [
    predicate1,
    predicate2
])
```

### 4. Error Handling
```swift
do {
    let messages = try context.fetch(request)
    return messages
} catch {
    print("Fetch error: \(error)")
    return []
}
```

## Data Flow in My App

### 1. App Launch
```
App starts → PersistenceController.shared → Load Core Data stack → 
CoreDataMessageStore.init() → loadMessages() → UI updates
```

### 2. Creating a Message
```
User taps Save → NewMessageView.saveMessage() → 
CoreDataMessageStore.addMessage() → PersistenceController.createMessage() → 
context.save() → loadMessages() → UI updates
```

### 3. Deleting a Message
```
User swipes → ContentView.deleteMessages() → 
CoreDataMessageStore.deleteMessage() → context.delete() → 
context.save() → loadMessages() → UI updates
```

### 4. Filtering Messages
```
User taps category → CoreDataMessageStore.loadMessagesByCategory() → 
PersistenceController.fetchMessages(category:) → UI updates
```

## Best Practices I'm Following

### 1. Context Management
- Always save context after changes
- Use main context for UI operations
- Handle errors gracefully
- Don't block UI thread with Core Data operations

### 2. Fetch Request Optimization
- Use specific predicates to limit results
- Add sort descriptors for consistent ordering
- Consider using `fetchLimit` for large datasets
- Use `fetchBatchSize` for memory efficiency

### 3. Error Handling
```swift
func save() {
    let context = container.viewContext
    
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            // Handle error appropriately
            print("Core Data save error: \(nsError)")
        }
    }
}
```

### 4. Performance Tips
- Fetch only what I need
- Use background contexts for heavy operations
- Implement proper error handling
- Monitor memory usage with large datasets

## Advantages Over UserDefaults

| Feature | UserDefaults | Core Data |
|---------|-------------|-----------|
| **Data Types** | Simple types only | Complex objects |
| **Querying** | Load all, filter in code | Database-like queries |
| **Performance** | Poor with large data | Optimized for large datasets |
| **Relationships** | Not supported | Full relationship support |
| **Scalability** | Limited | Handles thousands of records |
| **Search** | Manual implementation | Built-in search capabilities |

## Future Enhancements I Want to Add

### 1. CloudKit Integration
- Already configured with `NSPersistentCloudKitContainer`
- Automatic sync across devices
- Conflict resolution

### 2. Background Processing
- Use background contexts for heavy operations
- Batch operations for better performance
- Background fetch for updates

### 3. Data Migration
- Handle schema changes gracefully
- Version migration support
- Data transformation during updates
