//
//  CoreData.swift
//  VisionText
//
//  Created by JaredKozar on 1/1/22.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


func saveDocument(thumbnail: Data, title: String, text: String?) {
    
    let newDocument = Document(context: context)
    newDocument.thumbnail = thumbnail
    newDocument.title = title
    newDocument.date = Date()
    newDocument.isStarred = false
    newDocument.documentID = UUID().uuidString
    newDocument.text = text
    do {
          guard context.hasChanges else { return }
        try context.save()
    } catch {
        print("An error occured while saving the preset. \(error)")
    }
}

func fetchDocumentsByTitle(title: String) -> [Document] {
    let request = Document.fetchRequest() as NSFetchRequest<Document>
    
    request.predicate = NSPredicate(
        format: "title CONTAINS[cd] %@", title
    )
    
    var returnedDocs = [Document]()
    do {
        returnedDocs = try context.fetch(request)
    } catch {
        print("Fetch failed")
    }
    
    return returnedDocs
}

extension NSFetchedResultsControllerDelegate where Self: UIViewController{
    func returnFetchController(sortType: SortMethods, isStarred: Bool, searchTerm: String? = nil) -> NSFetchedResultsController<Document> {
        
        let sortDescriptor = NSSortDescriptor(key: sortType.coreDataTitle, ascending: sortType.ascending)
            let request = NSFetchRequest<Document>(entityName: "Document")
            request.sortDescriptors = [sortDescriptor]
            
        if isStarred == true {
            request.predicate = NSPredicate(format: "isStarred == YES")
        }
        
        if (searchTerm != nil) {
            request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchTerm!)
        }
        
        let documents = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        documents.delegate = self
        return documents
    }
}
