//
//  Constants.swift
//  DemoAlamofireWithAsyncAwait
//
//  Created by Krishnappa, Harsha on 28/03/2024.
//

import Foundation

/// A struct that holds constant values used throughout the application.

struct Constants {
    /// The base URL for the Google Books API.
    static let baseUrl = "https://www.googleapis.com/"
    /// The timeout duration for network requests, in seconds.
    static let timeout = 25.0
}

/// A struct that defines service endpoint paths for various network requests.
struct Services {
    /// The path for fetching books from the Google Books API. The `%@` placeholder is replaced with the search term.
    static let getBooks = "books/v1/volumes?q=%@"
}
