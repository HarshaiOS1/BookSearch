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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWriteAndWriteToCoredata() throws {
        let mockDataBook = [Book(id:123,volumeInfo: VolumeInfo(title: "book1", authors: ["auth1"], publisher: nil, publishedDate: nil, description: "this is testing mock book", imageLinks: nil), isFavorite: false), Book(id:123, volumeInfo: VolumeInfo(title: "book2", authors: ["auth2"], publisher: nil, publishedDate: nil, description: "this is testing mock book2", imageLinks: nil),isFavorite: false)]
        let viewModel = BooksViewModel.init(googleBookServices: FetchBookAPI())
        
        assert(viewModel.books.isEmpty, "viewmodel has no books")
        
        viewModel.saveBooksToCoreData(mockDataBook)
        viewModel.fetchBooksFromCoreData()
        print("adsasdfadf ")
        print(viewModel.books.count)
        print("adsasdfadf ")
        assert(!viewModel.books.isEmpty, "books are inserted to coredata and read from coredata")
    }
    
    func testMarkFavBook() {
        let mockDataBook = [Book(id:123,volumeInfo: VolumeInfo(title: "book1", authors: ["auth1"], publisher: nil, publishedDate: nil, description: "this is testing mock book", imageLinks: nil), isFavorite: false), Book(id:123, volumeInfo: VolumeInfo(title: "book2", authors: ["auth2"], publisher: nil, publishedDate: nil, description: "this is testing mock book2", imageLinks: nil),isFavorite: false)]
        let viewModel = BooksViewModel.init(googleBookServices: FetchBookAPI())
        let favBook = viewModel.books.filter { book in
            book.isFavorite == true
        }
        assert(favBook.isEmpty, "Initially no book marked fav")
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

