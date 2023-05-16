//
//  Document+CoreDataProperties.swift
//  VisionText
//
//  Created by Jared Kozar on 5/15/23.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var isStarred: Bool
    @NSManaged public var documentID: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var text: String?

}

extension Document : Identifiable {
    func deleteDocument() {
        context.delete(self)
        
        do {
            try context.save()
        } catch {
            print("An error occured while saving the preset.")
        }
    }
    
    
    func renameDocument(newTitle: String) {
        self.title = newTitle
        
        do {
            try context.save()
        } catch {
            print("An error occured while saving the preset.")
        }
    }
    
    func updateDocumentStarredStatus(isStarred: Bool) {
        
        self.isStarred = isStarred
        do {
            try context.save()
        } catch {
            print("An error occured while saving the preset. \(error)")
        }
    }
}
