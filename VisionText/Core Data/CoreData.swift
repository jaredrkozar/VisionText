//
//  CoreData.swift
//  VisionText
//
//  Created by JaredKozar on 1/1/22.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

func saveDocument(thumbnail: String, title: String, date: Date, isStarred: Bool = false, documentID: String, text: String?) {
  
    let newDocument = Document(context: context)
    newDocument.thumbnail = thumbnail
    newDocument.title = title
    newDocument.date = date
    newDocument.isStarred = isStarred
    newDocument.documentID = documentID
    newDocument.text = text
    do {
        try context.save()
    } catch {
        print("An error occured while saving the preset. \(error)")
    }
}

func updateDocument(document: Document, title: String, isStarred: Bool) {
    
    document.isStarred = isStarred
    document.title = title
    do {
        try context.save()
    } catch {
        print("An error occured while saving the preset. \(error)")
    }
}
func fetchDocuments(sortType: String, isAscending: Bool, isStarred: Bool) {
    let request = Document.createFetchRequest() as NSFetchRequest<Document>
    let sort = NSSortDescriptor(key: sortType, ascending: isAscending)
    request.sortDescriptors = [sort]

    if isStarred == true {
        request.predicate = NSPredicate(format: "isStarred == YES")
    }
    
    do {
        documents = try context.fetch(request)
    } catch {
        print("Fetch failed")
    }
}

func deleteDocument(document: Document) {
    context.delete(document)
    
    do {
        try context.save()
    } catch {
        print("An error occured while saving the preset.")
    }
}

