//
//  BooksViewModel.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation

class BooksViewModel: ObservableObject {
    private let googleBookServices: GoogleBookServices
    @MainActor @Published var errorMessage = ""
    @MainActor @Published var booksList: BooksList?
    
    init(googleBookServices: GoogleBookServices) {
        self.googleBookServices = googleBookServices
    }
    
    func fetchBooks(searchString: String) async {
        await MainActor.run {
            self.errorMessage = ""
        }
        let urlPath = String(format: Constants.baseUrl + Services.getBooks, searchString)
        if let result = await self.googleBookServices.fetchBooks(url: urlPath) {
            await MainActor.run {
                self.booksList = result
            }
        } else {
            await MainActor.run {
                self.errorMessage = "fetching data failed"
            }
        }
    }
}

//MARK: Google Services
protocol GoogleBookServices {
    func fetchBooks(url: String) async -> BooksList?
}

struct FetchBookAPI: GoogleBookServices {
    func fetchBooks(url: String) async -> BooksList? {
        do {
            guard let url = URL(string: url) else {
                throw URLError(.badURL)
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(BooksList.self, from: data)
            return result
        } catch  {
            return nil
        }
    }
}

