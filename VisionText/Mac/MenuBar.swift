//
//  MenuBar.swift
//  VisionText
//
//  Created by Jared Kozar on 7/25/21.
//

import UIKit

extension AppDelegate {
  override func buildMenu(with builder: UIMenuBuilder) {
      
      guard builder.system == .main else { return }
        // First remove the menus in the menu bar that are not needed, in this case the Format menu.
        builder.remove(menu: .format)
        
        // Adds import commands and keyboard shorcuts to the file menu
        builder.insertChild(importMenu(), atStartOfMenu: .file)
    
        // Adds sort documents commands and keyboard shorcuts to the view menu
        builder.insertChild(sortMenu(), atStartOfMenu: .view)
    }
        
    func importMenu() -> UIMenu {
        let cameracommand =
            UIKeyCommand(title: "Import from Camera",
                         image: nil,
                         action: #selector(AllDocsViewController.presentCamera),
                         input: "C",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let photosCommand =
            UIKeyCommand(title: "Import from Photos Library",
                         image: nil,
                         action: #selector(AllDocsViewController.presentPhotoPicker),
                         input: "P",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let urlCommand =
            UIKeyCommand(title: "Import from URL",
                         image: nil,
                         action: #selector(AllDocsViewController.presentURLPicker),
                         input: "U",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.openMenu"),
                   options: .displayInline,
                   children: [cameracommand, photosCommand, urlCommand])
        return openMenu
    }
    
    func sortMenu() -> UIMenu {
        
        let sortAZ =
            UIKeyCommand(title: "A-Z",
                         image: nil,
                         action: #selector(AllDocsViewController.sortDocsbyAZ),
                         input: "A",
                         modifierFlags: [.command],
                         propertyList: nil)
        sortAZ.discoverabilityTitle = "Sort Documents A-Z"
        
        let sortZA =
            UIKeyCommand(title: "Z-A",
                         image: nil,
                         action: #selector(AllDocsViewController.sortDocsByZA),
                         input: "A",
                         modifierFlags: [.command, .shift])
        sortZA.discoverabilityTitle = "Sort Documents Z-A"
        
        let sortDateAscending =
            UIKeyCommand(title: "Date (Ascending)",
                         image: nil,
                         action: #selector(AllDocsViewController.sortDocsbyDateAscending),
                         input: "D",
                         modifierFlags: [.command])
        sortDateAscending.discoverabilityTitle = "Sort Date (Ascending)"
        
        let sortDateDescending =
            UIKeyCommand(title: "Date (Descending)",
                         image: nil,
                         action: #selector(AllDocsViewController.sortDocsbyDateDescending),
                         input: "D",
                         modifierFlags: [.command, .shift])
        sortDateDescending.discoverabilityTitle = "Sort Date (Descending)"
        
        return UIMenu(title: "Sort Documents",
                      image: nil,
                      identifier: UIMenu.Identifier("com.jkozar.VisionText"),
                      options: .destructive,
                      children: [sortAZ, sortZA, sortDateAscending, sortDateDescending])
        
    }
}
