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
    
    func recognizeText(completion: @escaping(String?, String?)->()) {
        guard let cgimage = self.cgImage else { return completion(nil, "Cannot load image") }
        let textHandler = VNImageRequestHandler(cgImage: cgimage, options: [:])

        let request = VNRecognizeTextRequest { request, error in
            
            let observations = request.results as? [VNRecognizedTextObservation]

            let text = observations?.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")

            DispatchQueue.main.async {
                completion(text == "" ? "There is no text in this document. Please try scanning this document again or selecting a document form the list on the left" : text, nil)
            }

        }
        
        do {
            try textHandler.perform([request])
        } catch {
            completion(nil, "Cannot load image")
        }
    }
}
