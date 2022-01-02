//
//  Document+CoreDataProperties.swift
//  VisionText
//
//  Created by JaredKozar on 1/1/22.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var isStarred: Bool
    @NSManaged public var date: Date?
    @NSManaged public var documentID: String?

}

extension Document : Identifiable {

}
