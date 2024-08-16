//
//  BookDetailView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 15/08/2024.
//

import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: BooksViewModel
    @State var book: BookEntity
    
    var body: some View {
        HStack {
            if let url = book.thumbnail {
                CustomImageView(url: URL(string: url), placeholder: Image.init(systemName: "photo.on.rectangle.angled"))
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
    
    private func toggleFavorite() {
        book.isFavorite.toggle()
        viewModel.updateBookFavoriteStatus(book)
    }
}
