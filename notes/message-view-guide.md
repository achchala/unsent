# MessageView Implementation

## Overview

The **MessageView** system in unsent consists of multiple UI components that work together to display, create, and manage unsent messages. This guide covers the main views and their interactions that I built.

## Main Views Architecture

### 1. ContentView (Main List View)

**Purpose**: Main screen displaying all messages with filtering capabilities

**Key Features:**
- Message list with swipe-to-delete
- Category filtering with horizontal scroll
- Empty state handling
- Navigation to message creation

```swift
struct ContentView: View {
    @StateObject private var messageStore = CoreDataMessageStore()
    @State private var showingNewMessage = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                CategoryFilterView(messageStore: messageStore)
                
                // Messages List
                MessageListView(messageStore: messageStore)
            }
            .navigationTitle("unsent")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewMessage = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewMessage) {
                NewMessageView(messageStore: messageStore)
            }
        }
    }
}
```

### 2. NewMessageView (Message Creation)

**Purpose**: Form for creating new unsent messages

**Key Features:**
- Category selection grid
- Recipient input (optional)
- Privacy toggle
- Rich text editor
- Form validation

```swift
struct NewMessageView: View {
    @ObservedObject var messageStore: CoreDataMessageStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var selectedCategory = "general"
    @State private var isPrivate = true
    @State private var recipient = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                CategorySelectionGrid(selectedCategory: $selectedCategory)
                RecipientInputField(recipient: $recipient)
                PrivacyToggle(isPrivate: $isPrivate)
                MessageTextEditor(content: $content)
                Spacer()
            }
            .padding()
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveMessage() }
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
```

## UI Components

### 1. CategoryFilterView

**Purpose**: Horizontal scrolling category filter buttons

```swift
struct CategoryFilterView: View {
    @ObservedObject var messageStore: CoreDataMessageStore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" button
                CategoryButton(
                    title: "All", 
                    emoji: "💭", 
                    isSelected: messageStore.selectedCategory == nil
                ) {
                    messageStore.loadMessagesByCategory(nil)
                }
                
                // Category buttons
                ForEach(messageStore.getAllCategories(), id: \.self) { category in
                    CategoryButton(
                        title: category.capitalized,
                        emoji: messageStore.getCategoryEmoji(for: category),
                        isSelected: messageStore.selectedCategory == category
                    ) {
                        messageStore.loadMessagesByCategory(category)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}
```

**Key Features:**
- Horizontal scrolling for many categories
- Visual feedback for selected category
- Emoji icons for each category
- Smooth animations

### 2. CategoryButton

**Purpose**: Individual category filter button

```swift
struct CategoryButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(12)
        }
    }
}
```

**Design Principles:**
- Clear visual hierarchy (emoji + text)
- Consistent spacing and padding
- Visual feedback for selection state
- Accessible touch targets

### 3. MessageRowView

**Purpose**: Individual message display in the list

```swift
struct MessageRowView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with category and timestamp
            HStack {
                Text(getCategoryEmoji())
                    .font(.title2)
                Text(message.category?.capitalized ?? "General")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(message.timestamp ?? Date(), style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Message content (truncated)
            Text(message.content ?? "")
                .lineLimit(3)
                .font(.body)
            
            // Recipient (if exists)
            if let recipient = message.recipient, !recipient.isEmpty {
                Text("To: \(recipient)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
```

**Information Hierarchy:**
1. **Category & Timestamp** - Context and recency
2. **Message Content** - Primary information (truncated)
3. **Recipient** - Secondary information (if available)

### 4. CategorySelectionGrid

**Purpose**: Grid layout for category selection in new message form

```swift
struct CategorySelectionGrid: View {
    @Binding var selectedCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(getAllCategories(), id: \.self) { category in
                    CategorySelectionButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}
```

**Layout Features:**
- 4-column grid for optimal space usage
- Equal width buttons
- Consistent spacing
- Responsive to different screen sizes

### 5. MessageTextEditor

**Purpose**: Rich text input for message content

```swift
struct MessageTextEditor: View {
    @Binding var content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Message")
                .font(.headline)
            
            TextEditor(text: $content)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}
```

**UX Features:**
- Minimum height for comfortable typing
- Visual border and background
- Proper padding for text
- Rounded corners for modern look

## State Management

### 1. MessageStore Integration

All views use the `CoreDataMessageStore` for data management:

```swift
@StateObject private var messageStore = CoreDataMessageStore()
```

**Key Benefits:**
- Centralized data management
- Automatic UI updates when data changes
- Consistent data access across views

### 2. View State

**ContentView State:**
- `showingNewMessage` - Controls sheet presentation
- `messageStore` - Data management

**NewMessageView State:**
- `content` - Message text
- `selectedCategory` - Chosen category
- `isPrivate` - Privacy setting
- `recipient` - Optional recipient

## User Experience Features

### 1. Empty State Handling

```swift
if messageStore.messages.isEmpty {
    VStack(spacing: 16) {
        Image(systemName: "tray")
            .font(.system(size: 50))
            .foregroundColor(.gray)
        Text("No messages yet")
            .font(.title2)
            .foregroundColor(.gray)
        Text("Tap the + button to write your first unsent message")
            .font(.body)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

**Design Principles:**
- Clear call-to-action
- Helpful guidance text
- Appropriate iconography
- Centered layout

### 2. Form Validation

```swift
Button("Save") {
    saveMessage()
}
.disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
```

**Validation Rules:**
- Content cannot be empty
- Content cannot be only whitespace
- Save button disabled when invalid

### 3. Swipe-to-Delete

```swift
List {
    ForEach(messageStore.messages) { message in
        MessageRowView(message: message)
    }
    .onDelete(perform: deleteMessages)
}
```

**Interaction:**
- Standard iOS swipe gesture
- Immediate visual feedback
- Confirmation through haptic feedback

## Accessibility Features

### 1. VoiceOver Support

```swift
Button(action: action) {
    VStack(spacing: 4) {
        Text(emoji)
            .font(.title2)
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
    }
    // VoiceOver will read both emoji and text
}
```

### 2. Dynamic Type Support

```swift
Text("Your Message")
    .font(.headline) // Automatically scales with system settings
```

### 3. High Contrast Support

```swift
.foregroundColor(isSelected ? .blue : .primary) // Adapts to system theme
```

## Performance Considerations

### 1. Lazy Loading

```swift
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
    // Only renders visible items
}
```

### 2. Efficient Updates

```swift
@Published var messages: [Message] = []
// Only updates UI when data actually changes
```

### 3. Memory Management

```swift
.lineLimit(3) // Prevents layout calculations for long text
```

## Future Enhancements

### 1. Message Detail View

```swift
struct MessageDetailView: View {
    let message: Message
    @ObservedObject var messageStore: CoreDataMessageStore
    
    // Full message display
    // Edit functionality
    // Share options
}
```

### 2. Search Integration

```swift
struct SearchView: View {
    @ObservedObject var messageStore: CoreDataMessageStore
    @State private var searchText = ""
    
    // Search bar
    // Real-time filtering
    // Search results
}
```

### 3. Advanced Filtering

```swift
struct FilterView: View {
    @ObservedObject var messageStore: CoreDataMessageStore
    
    // Date range picker
    // Privacy filter
    // Combined filters
}
```