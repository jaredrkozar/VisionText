//
//  GlobalVariables.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import Vision

var documents = [Document]()
public var filterByStarred: Bool = false

private(set) var vc = AllDocsViewController()
private(set) var scanimage = ScannedImageViewController()

enum listofeffects: Double, CaseIterable {
    case half = 0.5
    case threequarters = 0.75
    case one = 1.0
    case oneandonequarter = 1.25
    case oneandonehalf = 1.5
    case oneandthreequarters = 1.75
    case two = 2.0
}

enum listofsortmethods: String, CaseIterable {
    case AZ = "A-Z"
    case ZA = "Z-A"
    case dateascending = "Date (Ascending)"
    case datedescending = "Date (Descending)"
}

public var sourceType: String = ""

public var sortMethod: String = ""


enum UIUserInterfaceIdiom {
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
    
    public var hasContent: Bool {
      return cgImage != nil || ciImage != nil
    }
    
    func recognizeText(completion: @escaping(String?, String?)->()) {
        guard let cgimage = self.cgImage else { return completion(nil, "Cannot load image") }
        let textHandler = VNImageRequestHandler(cgImage: cgimage, options: [:])

        let request = VNRecognizeTextRequest { request, error in
            
            let observations = request.results as? [VNRecognizedTextObservation]

            let text = observations?.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")

            DispatchQueue.main.async {
                completion(text, nil)
            }

        }
        
        do {
            try textHandler.perform([request])
        } catch {
            completion(nil, "Cannot load image")
        }
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

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
