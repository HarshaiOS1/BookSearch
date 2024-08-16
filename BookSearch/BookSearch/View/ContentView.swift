//
//  ContentView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI
import CoreData
import Lottie
/// `ContentView` is the main view of the application that displays a list of books and allows users to filter and search books.
/// It manages the presentation of books, handles network connectivity, and provides options to filter and search books.
///- Usage:
///   Use `ContentView` as the entry point for the book list interface. It integrates with `BooksViewModel` to manage data and display books,
///   supports searching and filtering, and handles network connectivity and offline access.
struct ContentView: View {
    @ObservedObject private var viewModel: BooksViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init(viewModel: BooksViewModel) {
        self.viewModel = viewModel
    }
    ///-`searchText`: A `State` variable that holds the current text entered by the user for searching books.
    @State private var searchText = ""
    ///-`showFavoritesOnly`: A `State` variable that determines whether to filter and show only favorite books.
    @State private var showFavoritesOnly = false
    ///-`showFilter`: A `State` variable that controls the display of the filter sheet.
    @State private var showFilter = false
    /// - Computed Properties:
    /// - `filteredBooks`: A computed property that filters the books based on the `showFavoritesOnly` state
    var filteredBooks: [BookEntity] {
        viewModel.books.filter {book in
            (!showFavoritesOnly || book.isFavorite)
        }
    }
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitle("Books", displayMode: .automatic)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            showFilter.toggle()
                        }) {
                            Text("Filter")
                        }
                    }
                }
        }
        .searchable(text: $searchText, prompt: Text("Search Online for new books.."))
        .onSubmit(of: .search) {
            handleSearchSubmit()
        }
        .onAppear {
            viewModel.fetchBooksFromCoreData()
        }
        .sheet(isPresented: $showFilter) {
            FilterView(viewModel: viewModel)
                .presentationDetents([.large])
        }
    }
    
    ///`content View`: A Group view that conditionally displays either the bookListView or noInternetView.
    private var contentView: some View {
        Group {
            if networkMonitor.isConnected || viewModel.isLoadOffline {
                bookListView
            } else {
                noInternetView
            }
        }
    }
    
    ///`bookListView`: Handles the display of the book list on search and  filtering for fav books
    private var bookListView: some View {
        List {
            if !networkMonitor.isConnected {
                Text("No Internet, Showing offline Data")
                    .foregroundStyle(Color.red)
            }
            Toggle(isOn: $showFavoritesOnly) {
                Text("Show Only Favorite Books")
            }
            ForEach(filteredBooks.prefix(10)) { book in
                NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                    BookRow(book: book)
                }
                .listRowSeparator(.hidden)
            }
            if filteredBooks.count > 10 {
                Section(header: Text("Previous Search Results").font(.title3)) {
                    ForEach(filteredBooks.dropFirst(10)) { book in
                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                            BookRow(book: book)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
    }
    
    ///`noInternetView`: Shows a message and a button to `load offline data from coredata` when there is no internet connection.
    private var noInternetView: some View {
        VStack(alignment: .center) {
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
        }
        .padding(.bottom, 150)
    }
    
    ///`handleSearchSubmit` handles the logic for  search submissions based on network connectivity.
    private func handleSearchSubmit() {
        if !networkMonitor.isConnected {
            viewModel.isLoadOffline = false
            viewModel.fetchBooksFromCoreData()
        } else {
            if searchText.count > 2 {
                viewModel.fetchAndSaveBooks(searchString: searchText)
            }
        }
    }
}

#Preview {
    ContentView(viewModel: BooksViewModel(googleBookServices: FetchBookAPI()))
        .environment(\.managedObjectContext, CoreDataManager.preview.context)
}
