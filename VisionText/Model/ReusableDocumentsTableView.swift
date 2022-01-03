//
//  ReusableDocumentsTableView.swift
//  VisionText
//
//  Created by JaredKozar on 12/16/21.
//

import UIKit

class ReusableDocumentsTableView: NSObject, UITableViewDataSource {

    var documentDetails = [Document]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let document = documentDetails[indexPath.row]

        cell.documentName.text = document.title

        cell.documentThumbnail.image = document.thumbnail!.toImage()?.downsizeImage(compression: 0.25, dimensions: CGSize(width: 109, height: 142))

        cell.documentDate.text = document.date?.formatted()
        
        if document.isStarred == true {
            cell.documentStatusImage.image = UIImage(systemName: "star.fill")
        } else {
            cell.documentStatusImage.image = nil
        }
       
        cell.accessibilityLabel = "\(String(describing: document.title)) Created on \(String(describing: document.date?.formatted()))"
        
        cell.layoutIfNeeded()
        return cell
    }
    
}
