//
//  FilterView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 16/08/2024.
//

import SwiftUI

/// `FilterView` is used to show filter screen where user can search among the locally saved books using author name or title
struct FilterView: View {
    /// The view model that manages the data and business logic for the books.
    @ObservedObject var viewModel: BooksViewModel
    /// This state variable tracks the user's input for searching books. The list of books is
    /// filtered based on this text.
    @State private var searchText = ""
    /// The environment variable used to dismiss the view.
    @Environment(\.dismiss) var dismiss
    /// The list of books filtered based on the search text.
    var filteredBooks: [BookEntity] {
        viewModel.filteredBooks(searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Saved Books using author or title..", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets(top: 0.0, leading: 10.0, bottom: 0.0, trailing: 10.0))
                List(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                        BookRow(book: book)
                    }
                    .listRowSeparator(.hidden)
                }
                .navigationTitle("Filter Books")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Close")
                        }
                    }
                }
                .onSubmit(of: .search) {
                    if searchText.count > 2 {
                        viewModel.fetchAndSaveBooks(searchString: searchText)
                    }
                }
            }
        }
    }
}
