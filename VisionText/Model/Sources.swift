//
//  Sources.swift
//  Sources
//
//  Created by Jared Kozar on 9/20/21.
//

import UIKit

enum Sources: CaseIterable {
    case scandoc
    case camera
    case photolibrary
    case files
    case url
    
    var icon: UIImage {
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .title1))
        
        switch self {
            case .scandoc:
            return UIImage(systemName: "doc.text.viewfinder", withConfiguration: config)!
            case .camera:
            return UIImage(systemName: "camera", withConfiguration: config)!
            case .photolibrary:
            return UIImage(systemName: "photo", withConfiguration: config)!
            case .files:
            return UIImage(systemName: "folder", withConfiguration: config)!
            case .url:
            return UIImage(systemName: "link", withConfiguration: config)!
                
        }
    }
    
    var title: String {
        
        switch self {
            case .scandoc:
                return "Scan Document"
            case .camera:
                return "Camera"
            case .photolibrary:
                return "Photo Library"
            case .files:
                return "Files"
            case .url:
                return "URL"
        }
    }
    
    static func getSource(name: String) -> Sources? {
        switch name {
            case "Scan Document":
                return .scandoc
            case "Camera":
                return .camera
            case "Photo Library":
                return .photolibrary
            case "Files":
                return .files
            case "URL":
                return .url
            default:
                return nil
        }
    }
    
    var availableOnMac: Bool {
        switch self {
        case .scandoc:
            return false
        default:
            return true
        }
    }
    
    var keyCommand: String {
        switch self {
        case .url:
            return "U"
        case .files:
            return "F"
        case .photolibrary:
            return "P"
        case .camera:
            return "C"
        case .scandoc:
            return "S"
        }
    }
}

extension Sources {
    func returnPresentView() -> SourceType {
        switch self {
        case .scandoc:
            return DocumentScan()
        case .camera:
            return CameraViewer()
        case .files:
            return FilesViewer()
        case .url:
            return URLViewer()
        case .photolibrary:
            return PhotoLibraryViewer()
        }
    }
}
