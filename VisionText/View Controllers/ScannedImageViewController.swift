//
//  ScannedImageViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit

class ScannedImageViewController: UIViewController {
    
    var document: Document?
    
    var isDocStarred: Bool?
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        let documentText = UITextView(frame: .zero, textContainer: nil)
        documentText.translatesAutoresizingMaskIntoConstraints = false
        documentText.text = document?.text
        documentText.font = UIFont.preferredFont(forTextStyle: .body)
        documentText.isEditable = false
        documentText.isSelectable = true
        self.view.addSubview(documentText)

        NSLayoutConstraint.activate([
            documentText.heightAnchor.constraint(equalToConstant: view.bounds.height),
            documentText.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            documentText.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            documentText.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor)
        ])
        
        
        let copyText = UIBarButtonItem(image: UIImage(systemName: "doc.text"), style: .plain, target: self, action: #selector(copyDocumentText(_:)))
        
        let speakText = UIBarButtonItem(image: UIImage(systemName: "play.circle"), style: .plain, target: self, action: #selector(speakText(_:)))
        
        navigationItem.rightBarButtonItems = [copyText, speakText]
        navigationItem.title = document?.title ?? "Untitled"
        if #available(iOS 16.0, *) {
            navigationItem.renameDelegate = self
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.navigationItem.setHidesBackButton(false, animated: true)
        case .pad, .mac:
            self.navigationItem.setHidesBackButton(true, animated: true)
        default:
            break
        }
    }
                                       
    @objc func copyDocumentText(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = document?.text
     }
    
    @objc func speakText(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = document?.text
     }
}

extension ScannedImageViewController: UINavigationItemRenameDelegate {
    func navigationItem(_: UINavigationItem, didEndRenamingWith title: String) {
        navigationItem.title = title
        updateDocument(document: document!, title: navigationItem.title ?? "Untitled", isStarred: isDocStarred ?? false)
        NotificationCenter.default.post(name: Notification.Name("reloadNotesTable"), object: nil)
        
    }
}
