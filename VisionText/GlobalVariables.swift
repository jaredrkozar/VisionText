//
//  GlobalVariables.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit

enum UIUserInterfaceIdiom: Int {
    case unspecified
    
    case phone
    case pad
    case mac
}

func makeThumbnail(thumbnail: UIImage, dimensions: CGSize) -> UIImage {
    var newDimensions = dimensions
    
    let widthRatio  = dimensions.width  / Double(thumbnail.size.width)
    let heightRatio = dimensions.height / Double(thumbnail.size.height)

    if(widthRatio > heightRatio) {
        newDimensions = CGSize(width: Double(thumbnail.size.width) * heightRatio, height: Double(Int(thumbnail.size.height)) * heightRatio)
    } else {
        newDimensions = CGSize(width: Double(thumbnail.size.width) * widthRatio, height: Double(thumbnail.size.height) * widthRatio)
    }
    print(newDimensions)
    //creates a new image based off of the dimensions found above
    UIGraphicsBeginImageContextWithOptions(newDimensions, false, 1.0)
    thumbnail.draw(in: CGRect(origin: .zero, size: newDimensions))
    let newThumbnail = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newThumbnail
}

extension Data {
    var uiImage: UIImage? { UIImage(data: self) }
}
