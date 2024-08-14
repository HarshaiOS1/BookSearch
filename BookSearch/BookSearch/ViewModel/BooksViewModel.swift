//
//  BooksViewModel.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation

class BooksViewModel: ObservableObject {
    private let googleBookServices: GoogleBookServices
    private var networkMonitor: NetworkMonitor
    @MainActor @Published var booksList: BooksList?
    @MainActor @Published var isConnected: Bool = true
    @MainActor @Published var errorMessage = ""
    
    
    init(googleBookServices: GoogleBookServices, networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.googleBookServices = googleBookServices
        self.networkMonitor = networkMonitor
        observeNetworkStatus()
    }
    
    private func observeNetworkStatus() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
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

