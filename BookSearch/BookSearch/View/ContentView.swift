//
//  ContentView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI
import CoreData
import Lottie

struct ContentView: View {
    @ObservedObject private var viewModel: BooksViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init(viewModel: BooksViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var refreshID:Int32 = 123
    
    var filteredBooks: [BookEntity] {
        viewModel.books.filter {book in
            (!showFavoritesOnly || book.isFavorite)
        }
    }
    
    //    List(documents, id: \.id) { item in
    
    
    var body: some View {
        NavigationView {
            if networkMonitor.isConnected || viewModel.isLoadOffline {
                List {
                    Toggle(isOn: $showFavoritesOnly) {
                        Text("Favorites only")
                    }
                    ForEach(filteredBooks.prefix(10)) { book in
                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                            BookRow(book: book)
                        }
                        .listRowSeparator(.hidden)
                    }
                    
                    if filteredBooks.count > 10 {
                        Section(header: Text("Previous search results")) {
                            ForEach(viewModel.books) { book in
                                NavigationLink {
                                    BookDetailView(viewModel: viewModel, book: book)
                                } label: {
                                    BookRow(book: book)
                                }
                                .listRowSeparator(.hidden)
                            }}
                    }
                }
                .navigationBarTitle("Books", displayMode: .large)
            } else if !networkMonitor.isConnected {
                VStack(alignment: .center , content: {
                    LottieView(filename: "NoInternet", isPaused: false)
                    Text("No Internet Connection")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button("Load Offline Data") {
                        viewModel.isLoadOffline = true
                        viewModel.fetchBooksFromCoreData()
                    }
                    .buttonStyle(.bordered)
                })
                Spacer()
                    .padding(.bottom, 150)
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            if !networkMonitor.isConnected {
                viewModel.fetchBooksFromCoreData()
                viewModel.isLoadOffline = false
            } else {
                if searchText.count > 2 {
                    viewModel.fetchAndSaveBooks(searchString: searchText)
                }
            }
        }
        .onAppear() {
            viewModel.fetchBooksFromCoreData()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView(viewModel: BooksViewModel(googleBookServices: FetchBookAPI()))
        .environment(\.managedObjectContext, CoreDataManager.preview.context)
}
