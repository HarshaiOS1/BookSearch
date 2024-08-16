//
//  BooksViewModel.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation
import CoreData
import Combine

/// A view model for managing and presenting book data.
///
/// The `BooksViewModel` class is responsible
/// 1. For fetching books from an external service (Google Books API),
/// 2. Saving books to Core Data, and managing the application's state related to books.
/// 3. It handles network connectivity, offline data loading, and error reporting.
/// 4. It conforms to the `ObservableObject` protocol, allowing SwiftUI views to bind to its published properties and react to changes.

class BooksViewModel: ObservableObject {
    private let googleBookServices: GoogleBookServices
    private let context = CoreDataManager.shared.context
    private var cancellables = Set<AnyCancellable>()
    
    /// The list of books currently held in Core Data.
    @Published var books: [BookEntity] = []
    /// A Boolean value indicating whether the device is currently connected to the network.
    @MainActor @Published var isConnected: Bool = true
    /// A Boolean value indicating whether the application is currently loading offline data.
    @MainActor @Published var isLoadOffline: Bool = false
    /// A string containing error messages related to book fetching or saving operations.
    @MainActor @Published var errorMessage = ""
    /// Initializes a new instance of `BooksViewModel` with the given Google Books service.
    ///
    /// - Parameter googleBookServices: An instance of `GoogleBookServices` used to fetch books from the Google Books API.
    init(googleBookServices: GoogleBookServices) {
        self.googleBookServices = googleBookServices
    }
    
    /// Fetches books from the Google Books API and saves them to Core Data.
    ///
    /// This function takes a search string provided by the user, constructs a URL based on the
    /// search term, and fetches a list of books from the Google Books API. Once the data is
    /// received, the books are saved to the local Core Data store for offline access.
    ///
    /// - Parameter searchString: The user's search query string to fetch books from the Google Books API.
    /// - Returns : Nil
    func fetchAndSaveBooks(searchString: String) {
        let cleanStr = (searchString as NSString).replacingOccurrences(of: " ", with: "+")
        let urlPath = String(format: Constants.baseUrl + Services.getBooks, cleanStr)
        googleBookServices.fetchBooks(url: urlPath)
            .sink(receiveCompletion: { [weak self]completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error fetching books: \(error.localizedDescription)"
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] booksList in
                self?.saveBooksToCoreData(booksList.items)
            })
            .store(in: &cancellables)
    }
    
    /// Filters the list of books based on a search query.
    ///
    /// This function takes a search string provided by the user,  Filters [BookEntity] to get Books who's authers or title matches with search string
    ///
    /// - Parameter searchText: The user's search query string to filter books list
    /// - Returns: [BookEntity] array of filtered books
    func filteredBooks(searchText: String) -> [BookEntity] {
        books.filter { book in
            searchText.isEmpty ||
            (book.title?.localizedCaseInsensitiveContains(searchText) == true ||
             book.authors?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }
}

//MARK: Coredata
extension BooksViewModel {
    /// Saves books to coredata
    ///
    /// This function Saves books from api response to coredata after mapping model values into entity
    ///
    /// - Parameter book: The `[Book]` whose favorite status will be updated.
    /// - Returns: Nil
    private func saveBooksToCoreData(_ books: [Book]) {
        books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.uniqueId = Int32(book.id)
            bookEntity.title = book.volumeInfo.title
            bookEntity.authors = book.volumeInfo.authors?.joined(separator: ", ")
            bookEntity.publisher = book.volumeInfo.publisher
            bookEntity.publishedDate = book.volumeInfo.publishedDate
            bookEntity.bookDescription = book.volumeInfo.description
            bookEntity.thumbnail = book.volumeInfo.imageLinks?.thumbnail
            bookEntity.isFavorite = book.isFavorite
            bookEntity.timestamp = Date()
        }
        do {
            try context.save()
            fetchBooksFromCoreData()
        } catch {
            print("Error saving books: \(error)")
        }
    }
    
    /// Fetch books from coredata
    ///
    /// This function retrieves the books from Core Data in reverse chronological order based on the timestamp and
    /// updates the `books` array, which drives the UI.
    ///
    /// - Parameter book: Nil
    /// - Returns: Nil
    func fetchBooksFromCoreData() {
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            books = try context.fetch(request)
        } catch {
            print("Error fetching books from Core Data: \(error)")
        }
    }
    
    /// Updates the favorite status of a specific book.
    ///
    /// This function toggles the favorite status of a book in the Core Data store and persists the change.
    ///
    /// - Parameter book: The `BookEntity` whose favorite status will be updated.
    /// - Returns: Nil
    func updateBookFavoriteStatus(_ book: BookEntity){
        context.perform {
            book.isFavorite.toggle()
            do {
                try self.context.save()
                self.fetchBooksFromCoreData()
            } catch {
                print("Error updating favorite status: \(error.localizedDescription)")
            }
        }
    }
    
}

//MARK: Google Services
/// The service used to fetch books from the Google Books API.
protocol GoogleBookServices {
    /// Fetches books from the Google Books API.
    ///
    /// - Parameter url: The URL to fetch the books from.
    /// - Returns: A publisher emitting `BooksList` on success or an error on failure.
    func fetchBooks(url: String) -> AnyPublisher<BooksList, Error>
}

struct FetchBookAPI: GoogleBookServices {
    /// Fetches books from the Google Books API implementaion of protocol
    func fetchBooks(url: String) -> AnyPublisher<BooksList, Error> {
        guard let url = URL(string: url) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: BooksList.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
