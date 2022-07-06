//
//  Document+CoreDataProperties.swift
//  VisionText
//
//  Created by JaredKozar on 7/5/22.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var date: Date?
    @NSManaged public var documentID: String?
    @NSManaged public var isStarred: Bool
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var text: String?

}

extension Document : Identifiable {

}
