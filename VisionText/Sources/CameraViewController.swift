//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Jared Kozar on 9/22/21.
//

import UIKit

extension AllDocsViewController: UIImagePickerControllerDelegate {
    
    @objc func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            guard let imageFromCamera = info[.editedImage] as? UIImage else {
                print("No image was found at this location. Please try again.")
                return
            }

            dismiss(animated: true, completion: nil)
            presentAlert(imageToPresent: imageFromCamera)
    }
    
}
