//
//  Constants.swift
//  DemoAlamofireWithAsyncAwait
//
//  Created by Krishnappa, Harsha on 28/03/2024.
//

import Foundation

struct Constants {
    static let baseUrl = "https://www.googleapis.com/"
    static let timeout = 25.0
}

struct Services {
    static let getBooks = "books/v1/volumes?q=%@"
}
