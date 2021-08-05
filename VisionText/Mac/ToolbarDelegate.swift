//
//  ToolbarDelegate.swift
//  VisionText
//
//  Created by Jared Kozar on 7/25/21.
//


import UIKit

class ToolbarDelegate: NSObject {
    #if targetEnvironment(macCatalyst)
    var shareRecipe: NSSharingServicePickerToolbarItem?
    #endif
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let sortDocs = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.sortDocs")
    static let addDoc = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.addDoc")
    static let shareDoc = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.shareDoc")
    static let getText = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.getText")
}

extension ToolbarDelegate: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .sortDocs,
            .addDoc,
            .flexibleSpace,
            .shareDoc,
            .getText
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem?
        
        switch itemIdentifier {
        case .sortDocs:
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.itemMenu = UIMenu(title: "JJJ", image: UIImage(systemName: "ellipsis.circle"), identifier: .window, options: .singleSelection, children: [UICommand(title: "A-Z", action: #selector(AllDocsViewController.sortDocsbyAZ)),
                                                                       UICommand(title: "Z-A", action: #selector(AllDocsViewController.sortDocsByZA)),
                                                                                                                                                           UICommand(title: "Date (Ascending)", action: #selector(AllDocsViewController.sortDocsbyDateAscending)),
                                                                                                                                                           UICommand(title: "A-Z", action: #selector(AllDocsViewController.sortDocsbyDateDescending))
                                                                                                                                                          ])
                    item.image = UIImage(systemName: "arrow.up.arrow.down")
                    return item
            
        case .addDoc:
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.itemMenu = UIMenu(title: "JJJ", image: UIImage(systemName: "ellipsis.circle"), identifier: .window, options: .singleSelection, children: [UICommand(title: "Camera", action: #selector(AllDocsViewController.presentCamera)),
                                                                                                                                                           UICommand(title: "Photo Library", action: #selector(AllDocsViewController.presentPhotoPicker)),
                                                                                                                                                           UICommand(title: "URL", action: #selector(AllDocsViewController.presentURLPicker))
                                                                                                                                                          ])
                    item.image = UIImage(systemName: "plus")
                    return item
            
        case .shareDoc:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "square.and.arrow.up")
            item.label = "Share Documents"
            item.action = #selector(ScannedImageViewController.shareButtonTapped)
            toolbarItem = item
            
        case .getText:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "doc.text.magnifyingglass")
            item.label = "Recognize Text"
            item.action = #selector(ScannedImageViewController.didTapRecognizeTextButton)
            toolbarItem = item
            
        
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }

    
}
#endif

