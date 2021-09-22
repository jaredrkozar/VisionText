//
//  FilesViewController.swift
//  FilesViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

extension AllDocsViewController: UIDocumentPickerDelegate {
    @objc func presentFilesPicker() {
        let documentpicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentpicker.delegate = self
            self.present(documentpicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else {
            return
        }
        
        myURL.startAccessingSecurityScopedResource()
        do {
            let imageData = try Data(contentsOf: myURL)
            let imageFromFiles = UIImage(data: imageData)!
            presentAlert(imageToPresent: imageFromFiles)
        } catch {
            print("There was an error loading the image: \(error). Please try again.")
        }
        
        myURL.startAccessingSecurityScopedResource()
        
    }
}
