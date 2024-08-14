//
//  BookSearchApp.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI

@main
struct BookSearchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
