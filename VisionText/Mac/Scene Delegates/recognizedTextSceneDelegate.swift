//  recognizedTextSceneDelegate.swift
//  recognizedTextSceneDelegate
//
//  Created by Jared Kozar on 9/18/21.
//
import UIKit

class RecognizedTextSceneDelegate: UIResponder, UIWindowSceneDelegate {
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
            let scannedTextView = RecognizedTextViewController()
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
            .copyText,
            .flexibleSpace,
            .shareDoc
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
<<<<<<< HEAD
            item.action = #selector(RecognizedTextViewController.speakText(_:))
=======
            item.action = #selector(ScannedImageViewController.speakText(_:))
>>>>>>> main
                toolbarItem = item
            
            case .soundSettings:
                item.image = UIImage(systemName: "gearshape")
                item.label = "Sound Settings"
<<<<<<< HEAD
            item.action = #selector(recognizedTextViewController.speakText)
=======
            item.action = #selector(ScannedImageViewController.showSoundOptions(_:))
>>>>>>> main
                toolbarItem = item
                
            case .copyText:
                item.image = UIImage(systemName: "doc.on.doc")
                item.label = "Copy Text"
<<<<<<< HEAD
            item.action = #selector(recognizedTextViewController.copyDocumentText(_:))
                toolbarItem = item
            
        case .shareDoc:
            item.image = UIImage(systemName: "square.and.arrow.up")
            item.label = "Share Text"
        item.action = #selector(recognizedTextViewController.shareText(_:))
            toolbarItem = item
        default:
            toolbarItem = nil
=======
            item.action = #selector(ScannedImageViewController.copyDocumentText(_:))
                toolbarItem = item
            
            default:
                toolbarItem = nil
>>>>>>> main
            
        }
        item.toolTip = item.label
        item.autovalidates = true
        return toolbarItem
    }
    
}

#endif
