//
//  Buttons.swift
//  Buttons
//
//  Created by Jared Kozar on 8/25/21.
//

import UIKit

class Buttons: UIView {

    func setRecognizedText() -> UITextView {
        let recognizedText = UITextView(frame: .zero, textContainer: nil)
        recognizedText.adjustsFontForContentSizeCategory = true
       
        recognizedText.font = UIFont.preferredFont(forTextStyle: .title1)
        recognizedText.isScrollEnabled = false
        recognizedText.showsVerticalScrollIndicator = true
        recognizedText.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        recognizedText.showsHorizontalScrollIndicator = true

        recognizedText.isUserInteractionEnabled = true
        
        recognizedText.isEditable = false
        
        return recognizedText
        
    }
    
    func addDoc() -> UIBarButtonItem {
        
        var listofsources = [UIAction]()
        
        for sort in Sources.allCases {
           
            listofsources.append( UIAction(title: "\(sort.title)", image: sort.icon, identifier: nil, attributes: []) { _ in
                
                sourceType = "\(sort.title)"
                
                NotificationCenter.default.post(name: Notification.Name("addImage"), object: nil)
           })
        }
        
        
        var sourcesMenu: UIMenu {
            return UIMenu(title: "Import image from...", image: nil, identifier: nil, options: [], children: listofsources)
        }
    
        let addDocButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: sourcesMenu)
        
        return addDocButton
        
    }
    
    func sortButton() -> UIBarButtonItem {
        
        var sortMethods = [UIAction]()
        
        for sort in listofsortmethods.allCases {
           sortMethods.append( UIAction(title: "\(sort.rawValue)", image: nil, identifier: nil, attributes: []) { _ in
               sortMethod = "\(sort.rawValue)"
               print(sort.rawValue)
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
