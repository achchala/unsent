//
//  NewMessageView.swift
//  unsent
//
//  Created by Achchala Deepan on 2025-08-12.
//

import SwiftUI

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
                // Category Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(messageStore.getAllCategories(), id: \.self) { category in
                            CategorySelectionButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                
                // Recipient (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recipient (Optional)")
                        .font(.headline)
                    
                    TextField("Who is this message for?", text: $recipient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Privacy Toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy")
                        .font(.headline)
                    
                    Toggle(isOn: $isPrivate) {
                        HStack {
                            Image(systemName: isPrivate ? "lock.fill" : "globe")
                            Text(isPrivate ? "Private" : "Public")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                // Message Content
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMessage()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveMessage() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRecipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        
        messageStore.addMessage(
            content: trimmedContent,
            category: selectedCategory,
            isPrivate: isPrivate,
            recipient: trimmedRecipient.isEmpty ? nil : trimmedRecipient
        )
        
        dismiss()
    }
}

// MARK: - Category Selection Button
struct CategorySelectionButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(getCategoryEmoji())
                    .font(.title2)
                Text(category.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryEmoji() -> String {
        switch category {
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
    NewMessageView(messageStore: CoreDataMessageStore())
}
