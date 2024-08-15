//
//  Books.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation

// MARK: - BooksList
struct BooksList: Decodable {
    let items: [Book]
}

struct Book: Codable, Identifiable {
    var id: Int = Int.random(in: 0..<7)
    let volumeInfo: VolumeInfo
    var isFavorite: Bool = false
    enum CodingKeys: String, CodingKey {
        case volumeInfo
    }
}

// MARK: - VolumeInfo
struct VolumeInfo: Codable {
    let title: String?
    let authors: [String]?
    let publisher, publishedDate, description: String?
    let imageLinks: ImageLinks?
}

// MARK: - ImageLinks
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String?
}
