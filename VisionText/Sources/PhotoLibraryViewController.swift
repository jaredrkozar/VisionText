//
//  PhotoLibraryViewController.swift
//  PhotoLibraryViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit
import PhotosUI

class PhotoLibraryViewer: NSObject, SourceType {
    
    weak var imageDelegate: ImageSelectedDelegate?
    
    private var imagePicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()
    
    weak var viewController: UIViewController?
    
    func presentView() {
        imagePicker.delegate = self
        self.viewController!.present(imagePicker, animated: true, completion: nil)
    }
}

extension PhotoLibraryViewer: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
 
        var selectedImages: [UIImage] = []
        DispatchQueue.main.async {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                    let resultingImage = object as? UIImage
                    selectedImages.append(resultingImage!)
                })
             }
        }
        picker.dismiss(animated: true, completion: {
            
            self.imageDelegate?.imageSelected(image: selectedImages)
        })
    }
}
