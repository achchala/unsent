//
//  CoreDataMessageStore.swift
//  unsent
//
//  Created by Achchala Deepan on 2025-08-12.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - Core Data Message Store
class CoreDataMessageStore: ObservableObject {
    @Published var messages: [Message] = []
    @Published var selectedCategory: String? = nil
    @Published var searchText: String = ""
    
    private let persistenceController = PersistenceController.shared
    
    init() {
        loadMessages()
    }
    
    // MARK: - CRUD Operations
    
    func addMessage(content: String, category: String, isPrivate: Bool, recipient: String?) {
        persistenceController.createMessage(
            content: content,
            category: category,
            isPrivate: isPrivate,
            recipient: recipient
        )
        loadMessages()
    }
    
    func deleteMessage(_ message: Message) {
        persistenceController.deleteMessage(message)
        loadMessages()
    }
    
    func updateMessage(_ message: Message) {
        persistenceController.save()
        loadMessages()
    }
    
    // MARK: - Data Loading
    
    func loadMessages() {
        messages = persistenceController.fetchMessages(
            category: selectedCategory,
            isPrivate: nil
        )
    }
    
    func loadMessagesByCategory(_ category: String?) {
        selectedCategory = category
        messages = persistenceController.fetchMessages(
            category: category,
            isPrivate: nil
        )
    }
    
    func loadPrivateMessages() {
        messages = persistenceController.fetchMessages(isPrivate: true)
    }
    
    func loadPublicMessages() {
        messages = persistenceController.fetchMessages(isPrivate: false)
    }
    
    // MARK: - Search
    
    func searchMessages(_ searchText: String) {
        self.searchText = searchText
        if searchText.isEmpty {
            loadMessages()
        } else {
            messages = persistenceController.searchMessages(searchText: searchText)
        }
    }
    
    // MARK: - Filtering
    
    func messagesByCategory(_ category: String) -> [Message] {
        return persistenceController.fetchMessages(category: category)
    }
    
    func privateMessages() -> [Message] {
        return persistenceController.fetchMessages(isPrivate: true)
    }
    
    func publicMessages() -> [Message] {
        return persistenceController.fetchMessages(isPrivate: false)
    }
    
    // MARK: - Statistics
    
    func messageCount() -> Int {
        return messages.count
    }
    
    func messageCountByCategory(_ category: String) -> Int {
        return messagesByCategory(category).count
    }
    
    func privateMessageCount() -> Int {
        return privateMessages().count
    }
    
    func publicMessageCount() -> Int {
        return publicMessages().count
    }
    
    // MARK: - Category Management
    
    func getCategoryEmoji(for category: String) -> String {
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
    
    func getAllCategories() -> [String] {
        return ["general", "apology", "confession", "loveLetter", "goodbye", "thankYou", "anger", "forgiveness"]
    }
}
