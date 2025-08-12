//
//  unsentApp.swift
//  unsent
//
//  Created by Achchala Deepan on 2025-08-12.
//

import SwiftUI

@main
struct unsentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
