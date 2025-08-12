//
//  ContentView.swift
//  unsent
//
//  Created by Achchala Deepan on 2025-08-12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var messageStore = CoreDataMessageStore()
    @State private var showingNewMessage = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "All", 
                            emoji: "💭", 
                            isSelected: messageStore.selectedCategory == nil
                        ) {
                            messageStore.loadMessagesByCategory(nil)
                        }
                        
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
                
                // Messages List
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
                } else {
                    List {
                        ForEach(messageStore.messages) { message in
                            MessageRowView(message: message)
                        }
                        .onDelete(perform: deleteMessages)
                    }
                }
            }
            .navigationTitle("Unspoken")
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
    
    private func deleteMessages(offsets: IndexSet) {
        for index in offsets {
            let message = messageStore.messages[index]
            messageStore.deleteMessage(message)
        }
    }
}

// MARK: - Category Button
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

// MARK: - Message Row View
struct MessageRowView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            Text(message.content ?? "")
                .lineLimit(3)
                .font(.body)
            
            if let recipient = message.recipient, !recipient.isEmpty {
                Text("To: \(recipient)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func getCategoryEmoji() -> String {
        switch message.category {
        case "general": return "💭"
        case "apology": return "🙏"
        case "confession": return "🤐"
        case "loveLetter": return "💌"
        case "goodbye": return "👋"
        case "thankYou": return "🙏"
        case "anger": return "😤"
        case "forgiveness": return "🤍"
        default: return "💭"
        }
    }
}

#Preview {
    ContentView()
}
