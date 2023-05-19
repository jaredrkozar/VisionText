//
//  SceneDelegate.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

#if targetEnvironment(macCatalyst)
var toolbarDelegate: NSToolbarDelegate?
#endif
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let splitViewController = UISplitViewController(style: .tripleColumn)
            splitViewController.preferredDisplayMode = .twoOverSecondary
            splitViewController.presentsWithGesture = true
            splitViewController.preferredSplitBehavior = .tile

            splitViewController.setViewController(SidebarViewController(), for: .primary)
            splitViewController.setViewController(AllDocsViewController(filterByStarred: false), for: .supplementary)
            splitViewController.setViewController(RecognizedTextViewController(), for: .secondary)
            
            splitViewController.setViewController(TabBarController(), for: .compact)
            
            splitViewController.primaryBackgroundStyle = .sidebar
            window.rootViewController = splitViewController
            self.window = window
            window.makeKeyAndVisible()
        }
        
        #if targetEnvironment(macCatalyst)
        guard let windowScene = scene as? UIWindowScene else { return }
        toolbarDelegate = mainToolbar()
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .expanded
        }
        
        #endif
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let sortDocs = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.sortDocs")
    static let addDoc = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.addDoc")
    static let shareDoc = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.shareDoc")
    static let copyText = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.copyText")
    static let isTextSpeaking = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.isTextSpeaking")
    static let soundSettings = NSToolbarItem.Identifier("com.jkozar.VisionText.VisionText.soundSettings")
}

class mainToolbar: NSObject {

}

extension mainToolbar: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .sortDocs,
            .addDoc,
            .flexibleSpace,
            .shareDoc,
            .copyText,
            .isTextSpeaking,
            .soundSettings,
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
        let allDocs: AllDocsViewController!
        
        switch itemIdentifier {
        case .sortDocs:
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.itemMenu = returnSortCommands()
            item.image = UIImage(systemName: "arrow.up.and.down.text.horizontal")
            
            return item
            
        case .addDoc:
            let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
            item.itemMenu = returnAddDocCommands()
            item.image = UIImage(systemName: "plus")
            
            return item
            
        case .shareDoc:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "square.and.arrow.up")
            item.label = "Share Documents"
            item.action = #selector(RecognizedTextViewController().shareText)
            item.isBordered = true
            toolbarItem = item
        
        case .copyText:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "doc.on.doc")
            item.label = "Copy Text"
        item.action = #selector(RecognizedTextViewController().copyText)
            toolbarItem = item
            
        case .isTextSpeaking:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "play.circle")
            item.label = "Speak Document Text"
            item.action = #selector(RecognizedTextViewController().playAudio)
            item.isBordered = true
            toolbarItem = item
            
        case .soundSettings:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "gear")
            item.label = "Audio Settings"
            item.action = #selector(RecognizedTextViewController().openAudioSettingsView)
            item.isBordered = true
            toolbarItem = item
            
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }
}
#endif


