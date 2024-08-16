//
//  Books.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation

// MARK: - BooksList
/// Represents a list of books fetched from an external API.
struct BooksList: Decodable {
    let items: [Book]
}

/// Represents a single book with its associated details.
/// The `Book` struct contains information about a book.
/// It also includes an `isFavorite` property to track if the book is marked as a favorite.
struct Book: Codable, Identifiable {
    var id: Int = Int.random(in: 0..<7)
    let volumeInfo: VolumeInfo
    var isFavorite: Bool = false
    enum CodingKeys: String, CodingKey {
        case volumeInfo
    }
}

// MARK: - VolumeInfo
/// Contains detailed information about a book's volume.
///
/// The `VolumeInfo` struct includes properties such as the title, authors, publisher, published date, description, and image links. 
/// These properties provide detailed metadata about the book.
struct VolumeInfo: Codable {
    let title: String?
    let authors: [String]?
    let publisher, publishedDate, description: String?
    let imageLinks: ImageLinks?
}

// MARK: - ImageLinks
/// Contains URLs to the book's cover images.
///
/// The `ImageLinks` struct provides URLs for different sizes of the book's cover image.
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String?
}
