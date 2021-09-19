//
//  recognizedTextSceneDelegate.swift
//  recognizedTextSceneDelegate
//
//  Created by Jared Kozar on 9/18/21.
//

import UIKit

class recognizedTextSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let scannedTextView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scannedText") as! recognizedTextViewController
            window.rootViewController = scannedTextView
            self.window = window
            window.makeKeyAndVisible()
        }
        
        
    }
}
