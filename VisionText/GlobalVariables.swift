//
//  GlobalVariables.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import Vision
import AVFoundation

var documents = [Document]()

func returnAddDocCommands() -> UIMenu {
    var addDocCommands = [UIKeyCommand]()
    
    for sort in Sources.allCases {
        if sort.availableOnMac {
            addDocCommands.append(UIKeyCommand(title: sort.title,
                                               action: #selector(AllDocsViewController.selectedMenuItem),
                                               input: sort.keyCommand,
                                               modifierFlags: .command, propertyList: ["addDoc": sort.title]))
        }
    }
    
    return UIMenu(title: "Add Document", image: nil, identifier: nil, options: [], children: addDocCommands)
}

func returnSortCommands() -> UIMenu {
    var sortCommands = [UICommand]()
    
    for sort in SortMethods.allCases {
        sortCommands.append(UICommand(title: sort.buttonText, action: #selector(AllDocsViewController.selectedMenuItem), propertyList: ["sortType": sort.buttonText]))
    }
    
    return UIMenu(title: "Sort Documents", image: nil, identifier: nil, options: [], children: sortCommands)
}

enum SortMethods: CaseIterable {
    case AZ
    case ZA
    case dateascending
    case datedescending
    
    var buttonText: String {
        switch self {
        case .AZ:
            return "A-Z"
        case .ZA:
            return "Z-A"
        case .dateascending:
            return "Date (Ascending)"
        case .datedescending:
            return "Date (Descending)"
        }
    }
    
    var ascending: Bool {
        switch self {
            case .AZ, .dateascending:
                return true
            default:
                return false
        }
    }
    
    var coreDataTitle: String {
        switch self {
        case .AZ, .ZA:
            return "title"
        case .datedescending, .dateascending:
            return "date"
        }
    }
    
    static func getSortMethod(name: String) -> SortMethods? {
        switch name {
            case "A-Z":
                return .AZ
            case "Z-A":
                return .ZA
            case "Date (Ascending)":
                return .dateascending
            case "Date (Descending)":
                return .datedescending
            default:
                return nil
        }
    }
}

enum UIUserInterfaceIdiom {
    case unspecified
    
    case phone
    case pad
    case mac
}

extension Data {
    var uiImage: UIImage? { UIImage(data: self) }
}

extension UIImage {
    func downsizeImage() -> Data {
        let maxSize = CGSize(width: 100, height: 150)

        let availableRect = AVFoundation.AVMakeRect(aspectRatio: self.size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let image = self
        let resized = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        print(resized.size)
        return resized.pngData()!
    }
}

extension Array where Self == [UIImage] {
    func recognizeText(images: [UIImage], completion: @escaping(String?, String?)->()) {
        var recognizedText = ""
        
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print(String(describing: error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("Could not retrieve text observations")
                return
            }
            
            let maximumRecognitionCandidates = 1
            
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                    print("No recognition candidates")
                    continue
                }
                
                recognizedText += "\(candidate.string)\n"
            }
        }
        
        recognizeTextRequest.recognitionLevel = .accurate
        
        for image in images {
            let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
        }
        
        DispatchQueue.main.async {
            
            completion(recognizedText == "" ? "There is no text in this document. Please try scanning this document again or selecting a document form the list on the left" : recognizedText, nil)
        }
    }
}
