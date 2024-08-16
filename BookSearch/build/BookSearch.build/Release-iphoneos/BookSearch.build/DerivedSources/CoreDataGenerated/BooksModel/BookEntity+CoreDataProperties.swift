//
//  BookEntity+CoreDataProperties.swift
//  
//
//  Created by Krishnappa, Harsha on 16/08/2024.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var authors: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var publishedDate: String?
    @NSManaged public var publisher: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var uniqueId: Int32

}

extension BookEntity : Identifiable {

}
