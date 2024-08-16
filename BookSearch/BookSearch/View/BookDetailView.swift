//
//  BookDetailView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import SwiftUI

/// `BookDetailView` presents detailed information about a specific book.
///
/// This view displays the book's thumbnail, title, authors, and description. It also includes a favorite button to toggle the book's favorite status.
///
/// - Note: The `book` property is a `BookEntity` that represents the book to be displayed.
/// The `viewModel` property is used to interact with the underlying data model for updating the book's favorite status.
struct BookDetailView: View {
    /// The view model that provides data and functionality related to books.
    @ObservedObject var viewModel: BooksViewModel
    /// The book entity whose details are to be displayed.
    @State var book: BookEntity
    
    var body: some View {
        HStack {
            if let url = book.thumbnail {
                CustomImageView(url: URL(string: url),placeholder: Image.init(systemName: "photo.on.rectangle.angled"))
                    .frame(maxWidth: 100)
            }
            VStack {
                HStack {
                    Text(book.title ?? "")
                        .font(.headline)
                    Spacer()
                    FavoriteButton(isSet: $book.isFavorite, onToggle: {
                        toggleFavorite()
                    })
                    .frame(width: 15, height: 15)
                }
                Divider()
                Text("\n Authors : \(book.authors ?? "")")
                    .font(.subheadline)
            }
        }
        .frame(width: (UIScreen.main.bounds.width - 100), height: 200)
        Divider()
        ScrollView {
            Text(book.bookDescription ?? "Description not found")
                .padding(.all)
        }
        .navigationTitle("Book Details")
    }
    
    /// Toggles the favorite status of the book and updates the view model.
    ///
    /// This function changes the `isFavorite` property of the book and calls the `updateBookFavoriteStatus` method on the view model
    /// to persist the change.
    private func toggleFavorite() {
        book.isFavorite.toggle()
        viewModel.updateBookFavoriteStatus(book)
    }
}
