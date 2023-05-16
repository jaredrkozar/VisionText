//
//  FilesViewController.swift
//  FilesViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class FilesViewer: NSObject, SourceType, UIDocumentPickerDelegate {

    weak var viewController: UIViewController?
    
    var imageDelegate: ImageSelectedDelegate?
    
    var topMostView: UIViewController?
    
    func presentView() {
        let documentpicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentpicker.delegate = self
        viewController?.present(documentpicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
             }
        self.imageDelegate?.imageSelected(image: UIImage(contentsOfFile: url.relativePath)!)
    }
}
