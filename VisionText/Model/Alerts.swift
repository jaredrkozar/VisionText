//
//  Alerts.swift
//  VisionText
//
//  Created by Jared Kozar on 4/5/23.
//

import UIKit

struct Alerts {

    func presentLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Recognizing Text", message: " ", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
           indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
           //add the activity indicator as a subview of the alert controller's view
            alert.view.addSubview(indicator)
           indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
           indicator.startAnimating()
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }

    func presentNameAlert(alertTitle: String?, completionHandler: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
            let answer = alert.textFields![0]
            // do something interesting with "answer" here
            completionHandler(answer.text)
        }

        alert.addAction(submitAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }

    
}
