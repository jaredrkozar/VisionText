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
        builder.insertChild(returnAddDocCommands(), atStartOfMenu: .file)
        builder.insertChild(returnSortCommands(), atStartOfMenu: .view)
        
    }
}
