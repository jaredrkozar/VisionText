//
//  SoundSettingsSceneDelegate.swift
//  SoundSettingsSceneDelegate
//
//  Created by Jared Kozar on 9/19/21.
//

import UIKit

class SoundSettingsSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
#if targetEnvironment(macCatalyst)
var toolbarDelegate: NSToolbarDelegate?
#endif
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.showsBaselineSeparator = false
        
        windowScene.title = "Sound Settings"
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
            titlebar.separatorStyle = .shadow
        }
        #endif
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let soundSettings = SoundSettingsViewController()
            soundSettings.preferredContentSize = CGSize(width: 350, height: 225)
            window.rootViewController = soundSettings
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 350, height: 225)
            self.window = window
            window.makeKeyAndVisible()
        }
        
    }
}
