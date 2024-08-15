//
//  BookSearchApp.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI

@main
struct BookSearchApp: App {
    let coredataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: BooksViewModel(googleBookServices: FetchBookAPI()))
                .environment(\.managedObjectContext, coredataManager.persistentContainer.viewContext)
        }
    }
}
