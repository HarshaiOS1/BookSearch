//
//  Books.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import Foundation

// MARK: - Welcome
struct BooksList: Decodable {
    let items: [Book]
}

struct Book: Identifiable, Decodable {
    var id: String {
        volumeInfo.title! + (volumeInfo.authors?.first)!
    }
    let volumeInfo: VolumeInfo
    var isFavorite: Bool = false
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
