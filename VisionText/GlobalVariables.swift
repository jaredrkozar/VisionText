//
//  GlobalVariables.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
private(set) var vc = AllDocsViewController()

public var sourceTyper: String {
    get{
       return vc.sourceType
    }
    set{
       vc.sourceType = newValue
    }
}

public var sortMethod: String {
    get{
       return vc.sortMethod
    }
    set{
       vc.sortMethod = newValue
    }
}


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

extension UIImage {
    func downsizeImage(compression: Double, dimensions: CGSize) -> UIImage {
        let thumbnailasdata = self.jpegData(compressionQuality: compression)
        var thumbnail = thumbnailasdata?.uiImage
        thumbnail = makeThumbnail(thumbnail: thumbnail!, dimensions: dimensions)
        return thumbnail!
    }
    
    func converttoString() -> String {
        let data = self.jpegData(compressionQuality: 1)
        return (data?.base64EncodedString(options: .endLineWithLineFeed))!
            
    }
    
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

extension Array where Element == Documents {
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "documentDetails")
        }
    }
    
    mutating func load() -> [Documents] {
        if let saveddetailedDocs = UserDefaults.standard.object(forKey: "documentDetails") as? Data {
            if let decodeddetailedDocs = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(saveddetailedDocs) as? [Documents] {
                self = decodeddetailedDocs
            }
        }
        return self
    }
}
