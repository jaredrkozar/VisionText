//
//  PhotoLibraryViewController.swift
//  PhotoLibraryViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit
import PhotosUI

extension AllDocsViewController: PHPickerViewControllerDelegate {
    
    @objc func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let imageFromPhotosLibrary = image as? UIImage else { return }
                    
                    self.presentAlert(imageToPresent: imageFromPhotosLibrary)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
