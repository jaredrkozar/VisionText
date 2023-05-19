//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit

class CameraViewer: NSObject, SourceType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var viewController: UIViewController?
    
    
    var imageDelegate: ImageSelectedDelegate?
    
    func presentView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        viewController?.present(imagePickerController, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("No image was found at this location. Please try again.")
            picker.dismiss(animated: true)

            guard let imageFromCamera = info[.editedImage] as? UIImage else {
                print("No image was found at this location. Please try again.")
                return
            }

        self.imageDelegate?.imageSelected(image: [imageFromCamera])
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("No image was found at this location. Please try again.")
        picker.dismiss(animated: true)
    }
}
