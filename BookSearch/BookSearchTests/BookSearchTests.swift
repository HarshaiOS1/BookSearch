//
//  BookSearchTests.swift
//  BookSearchTests
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import XCTest
@testable import BookSearch
import Combine

final class BookSearchTests: XCTestCase {
    var viewModel: BooksViewModel!
    var mockService: MockFetchBookAPI!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        mockService = MockFetchBookAPI()
        viewModel = BooksViewModel(googleBookServices: mockService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    private func getMockdata() -> [Book] {
        let mockDataBook = [Book(id:123,volumeInfo: VolumeInfo(title: "book1", authors: ["author1"], publisher: nil, publishedDate: nil, description: "this is testing mock book", imageLinks: nil), isFavorite: false),
                            Book(id:1234,volumeInfo: VolumeInfo(title: "book2", authors: ["author2"], publisher: nil, publishedDate: nil, description: "this is testing mock book", imageLinks: nil), isFavorite: false)]
        return mockDataBook
    }
    
    func testFetchAndSaveBooks_success() {
        viewModel.clearAllBooksFromCoreData()
        let books = getMockdata()
        mockService.booksList = BooksList(items: books)
        
        let expectation = XCTestExpectation(description: "Books fetched and saved to coredata")
        viewModel.fetchAndSaveBooks(searchString: "testing")
        
        viewModel.$books
            .sink { books in
                if !books.isEmpty {
                    let testbook = books.filter { $0.title == "book1"}
                    XCTAssertEqual(testbook.first?.authors, "author1")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation],timeout: 1.0)
    }
    
    func testFetchAndSaveBooks_failure() {
        mockService.shouldReturnError = true
        let expectation = XCTestExpectation(description: "Error message set after failed fetch")
        viewModel.fetchAndSaveBooks(searchString: "Testing")
        
        viewModel.$errorMessage
            .sink { errorMessage in
                if !errorMessage.isEmpty {
                    XCTAssertEqual(errorMessage, "Error fetching books: The operation couldn’t be completed. (NSURLErrorDomain error -1011.)")
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        wait(for: [expectation],timeout: 1.0)
    }
    
    func testWriteAndWriteToCoredata() throws {
        let books = getMockdata()
        assert(viewModel.books.isEmpty, "viewmodel has no books")
        viewModel.saveBooksToCoreData(books)
        assert(!viewModel.books.isEmpty, "books are inserted to coredata and read from coredata")
    }
    
    func testFilteredBooks() {
        viewModel.clearAllBooksFromCoreData()
        let books = getMockdata()
        assert(viewModel.books.isEmpty, "viewmodel has no books")
        viewModel.saveBooksToCoreData(books)
        
        let filteredBooks = viewModel.filteredBooks(searchText: "book1")
        XCTAssertEqual(filteredBooks.first?.authors, "author1")
    }
    
    func testFavMarkingABook() {
        let books = getMockdata()
        viewModel.saveBooksToCoreData(books)
        var favBooks = viewModel.books.filter {$0.isFavorite == true}
        assert(favBooks.count == 0," No fav books")
        if let markBook = viewModel.books.last {
            markBook.isFavorite = true
            viewModel.updateBookFavoriteStatus(markBook)
        }
        favBooks = viewModel.books.filter {$0.isFavorite == true}
        assert(favBooks.count == 1," No fav books")
    }
    
    func testClearAllBooksFromCoreData() {
        viewModel.clearAllBooksFromCoreData()
        let books = getMockdata()
        assert(viewModel.books.isEmpty, "viewmodel has no books")
        viewModel.saveBooksToCoreData(books)
        assert(viewModel.books.count > 0, "viewmodel got books from coredata")
        viewModel.clearAllBooksFromCoreData()
        XCTAssertEqual(viewModel.books.count, 0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

//MARK: MockFetchBookAPI
///The MockFetchBookAPI class is a mock implementation of the GoogleBookServices protocol, designed to simulate the behavior of the actual GoogleBookServices in unit tests.
///It allows you to control whether the service returns successful book data or an error, making it useful for testing different scenarios in your ViewModel without relying on network calls.

class MockFetchBookAPI: GoogleBookServices {
    var shouldReturnError = false
    var booksList: BooksList?
    
    func fetchBooks(url: String) -> AnyPublisher<BooksList, any Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        } else {
            let booksList = self.booksList ?? BooksList(items: [])
            return Just(booksList)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
