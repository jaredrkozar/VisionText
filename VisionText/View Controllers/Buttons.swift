//
//  Buttons.swift
//  Buttons
//
//  Created by Jared Kozar on 8/25/21.
//

import UIKit

class Buttons: UIView {

    func setRecognizedText() -> UITextView {
        let recognizedText = UITextView()
        recognizedText.adjustsFontForContentSizeCategory = true
       
        recognizedText.font = UIFont.preferredFont(forTextStyle: .title1)
        recognizedText.isScrollEnabled = true
        recognizedText.showsVerticalScrollIndicator = true
        recognizedText.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        recognizedText.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        recognizedText.showsHorizontalScrollIndicator = true
        
        recognizedText.frame = CGRect(x: 3.0, y: 10.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        recognizedText.translatesAutoresizingMaskIntoConstraints = true
        recognizedText.isUserInteractionEnabled = true
        
        recognizedText.isEditable = false
        
        return recognizedText
        
    }
    
    func addDoc() -> UIBarButtonItem {
        
        var sources: [UIAction] {
            return [
                UIAction(title: "Scan Document", image: UIImage(systemName: "doc.text.viewfinder"), handler: { (_) in
                    sourceTyper = "Scan Document"
                    NotificationCenter.default.post(name: Notification.Name("addImage"), object: nil)
                }),
                
                UIAction(title: "Camera", image: UIImage(systemName: "camera"), handler: { (_) in
                    sourceTyper = "Camera"
                    NotificationCenter.default.post(name: Notification.Name( "addImage"), object: nil)
                }),
                
                UIAction(title: "Photo Library", image: UIImage(systemName: "photo"), handler: { (_) in
                    sourceTyper = "Photo Library"
                    NotificationCenter.default.post(name: Notification.Name( "addImage"), object: nil)
                }),
                
                UIAction(title: "Files", image: UIImage(systemName: "folder"), handler: { (_) in
                    sourceTyper = "Files"
                    NotificationCenter.default.post(name: Notification.Name( "addImage"), object: nil)
                }),
                
                UIAction(title: "URL", image: UIImage(systemName: "link"), handler: { (_) in
                    sourceTyper = "URL"
                    NotificationCenter.default.post(name: Notification.Name( "addImage"), object: nil)
                }),
            ]
           
        }
        
        var sourcesMenu: UIMenu {
            return UIMenu(title: "Import image from...", image: nil, identifier: nil, options: [], children: sources)
        }
    
        let addDocButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: sourcesMenu)
        
        return addDocButton
        
    }
    
    func sortButton() -> UIBarButtonItem {
        
        var sortMethods = [UIAction]()
        
        for sort in listofsortmethods.allCases {
           sortMethods.append( UIAction(title: "\(sort.rawValue)", image: nil, identifier: nil, attributes: []) { _ in
               sortMethod = "\(sort.rawValue)"
               NotificationCenter.default.post(name: Notification.Name( "changedsortType"), object: nil)
           })
        }

        
        var sortMenu: UIMenu {
            return UIMenu(title: "Sort documents by...", image: nil, identifier: nil, options: [.singleSelection], children: sortMethods)
        }
        
        let sortButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: nil, menu: sortMenu)
        
        return sortButton
    }
    
}
