//
//  URLViewController.swift
//  URLViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit

class URLViewer: NSObject, SourceType {

    weak var viewController: UIViewController?
    
    var imageDelegate: ImageSelectedDelegate?
    
    func presentView() {
        let nameAlert = Alerts().presentNameAlert(alertTitle: "Enter URL", completionHandler: { title in

            let url = URL(string: title!)
            if UIApplication.shared.canOpenURL(url! as URL) == true {
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let imageFromURL = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.imageDelegate?.imageSelected(image: imageFromURL)
                            }
                        }
                    }
                }
            } else {
                let invalidURL = UIAlertController(title: "Invalid URL", message: "The direct image URL you entered is invalid. Please enter another URL.", preferredStyle: .alert)

                invalidURL.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                self.viewController?.present(invalidURL, animated: true)
            }
        })
        
        viewController?.present(nameAlert, animated: true)
    }
}
