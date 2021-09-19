//
//  recognizedTextSceneDelegate.swift
//  recognizedTextSceneDelegate
//
//  Created by Jared Kozar on 9/18/21.
//

import UIKit

class recognizedTextSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
#if targetEnvironment(macCatalyst)
var toolbarDelegate: NSToolbarDelegate?
#endif

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
        #if targetEnvironment(macCatalyst)
        toolbarDelegate = resizedImagesToolbarDelegate()
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false

        windowScene.title = "Recognized Text"

        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
            titlebar.separatorStyle = .shadow
        }
        #endif
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let scannedTextView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scannedText")
            window.rootViewController = scannedTextView
            self.window = window
            window.makeKeyAndVisible()
        }
        
        
    }
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let isTextSpeaking = NSToolbarItem.Identifier("com.jkozar.VisionText.isTextSpeaking")
    static let soundSettings = NSToolbarItem.Identifier("com.jkozar.VisionText.soundSettings")
    static let copyText = NSToolbarItem.Identifier("com.jkozar.VisionText.copyText")
}

class resizedImagesToolbarDelegate: NSObject {
}

extension resizedImagesToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItemGroup.Identifier] = [
            .isTextSpeaking,
            .soundSettings,
            .copyText
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
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.isBordered = true
        item.target = nil
        switch itemIdentifier {
            case .isTextSpeaking:
                item.image = UIImage(systemName: "speaker.wave.3")
            item.action = #selector(recognizedTextViewController.speakText(_:))
                toolbarItem = item
            
            case .soundSettings:
                item.image = UIImage(systemName: "gearshape")
                item.label = "Sound Settings"
            item.action = #selector(recognizedTextViewController.soundSettings(_:))
                toolbarItem = item
                
            case .copyText:
                item.image = UIImage(systemName: "doc.on.doc")
                item.label = "Copy Text"
            item.action = #selector(recognizedTextViewController.copyButtonTapped(_:))
                toolbarItem = item
            default:
                toolbarItem = nil
            
        }
        item.toolTip = item.label
        item.autovalidates = true
        return toolbarItem
    }
    
}

#endif


