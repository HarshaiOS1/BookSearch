//
//  BooksViewModel.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation
import CoreData
import Combine

class BooksViewModel: ObservableObject {
    private let googleBookServices: GoogleBookServices
    
    private let context = CoreDataManager.shared.context
    @Published var books: [BookEntity] = []
    private var cancellables = Set<AnyCancellable>()
    //    private let api = BooksAPI()
    
    //    @MainActor @Published var booksList: BooksList?
    @MainActor @Published var isConnected: Bool = true
    @MainActor @Published var isLoadOffline: Bool = false
    @MainActor @Published var errorMessage = ""
    
    init(googleBookServices: GoogleBookServices) {
        self.googleBookServices = googleBookServices
    }
    
    func fetchAndSaveBooks(searchString: String) {
        let cleanStr = (searchString as NSString).replacingOccurrences(of: " ", with: "+")
        let urlPath = String(format: Constants.baseUrl + Services.getBooks, cleanStr)
        googleBookServices.fetchBooks(url: urlPath)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching books: \(error)")
                    //harsha : error hanlde
                    //                    await MainActor.run {
                    //                        self.errorMessage = error.localizedDescription
                    //                    }
                }
            }, receiveValue: { [weak self] booksList in
                self?.saveBooksToCoreData(booksList.items)
            })
            .store(in: &cancellables)
    }
    
    //MARK: save books from api response to coredata
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
    
    //MARK: fetch books from coredata
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
    
    func updateBookFavoriteStatus(_ book: BookEntity) {
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
protocol GoogleBookServices {
    func fetchBooks(url: String) -> AnyPublisher<BooksList, Error>
}

struct FetchBookAPI: GoogleBookServices {
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
