//
//  DocumentScanViewController.swift
//  DocumentScanViewController
//
//  Created by Jared Kozar on 9/21/21.
//

import UIKit

import VisionKit
import Vision

class DocumentScan: NSObject, SourceType, VNDocumentCameraViewControllerDelegate {

    weak var viewController: UIViewController?
    
    var imageDelegate: ImageSelectedDelegate?

    func presentView() {
        let docCamera = VNDocumentCameraViewController()
        docCamera.delegate = self
        viewController?.present(docCamera, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        let errorAlert = UIAlertController(title: "Failed to scan document", message: "The document couldn't be scanned right now. Please try again.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        controller.present(errorAlert, animated: true)
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller:            VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        
        controller.dismiss(animated: true)
        var selectedImages: [UIImage] = []
        
        for i in 0..<scan.pageCount {
            selectedImages.append(scan.imageOfPage(at: i))
          }
        
        imageDelegate?.imageSelected(image: selectedImages)
    }
    
}
