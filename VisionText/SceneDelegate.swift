//
//  SceneDelegate.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var toolbarDelegate = ToolbarDelegate()

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
            splitViewController.setViewController(TabBarController(), for: .compact)
            splitViewController.setViewController(ScannedImageViewController(), for: .secondary)
            
            splitViewController.primaryBackgroundStyle = .sidebar
            window.rootViewController = splitViewController
            self.window = window
            window.makeKeyAndVisible()
            
        }
        
        #if targetEnvironment(macCatalyst)
        guard let windowScene = scene as? UIWindowScene else { return }

        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
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


class ToolbarDelegate: NSObject {

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



