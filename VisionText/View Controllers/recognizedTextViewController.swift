//
//  ScannedImageViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import AVFoundation

class RecognizedTextViewController: UIViewController, AVSpeechSynthesizerDelegate, UINavigationItemRenameDelegate {
    
    func navigationItem(_: UINavigationItem, didEndRenamingWith title: String) {
        document?.renameDocument(newTitle: title)
    }
    
    var document: Document?
    private var audioManager: AudioManager?
    private var documentAttributedText: NSMutableAttributedString?
    private var shouldHighlightCurrentWord: Bool = false
    
    internal var audioMenu: UIBarButtonItem!
    
    lazy var noDocumentLabel: UILabel = {
        let noDocLabel = UILabel()
        noDocLabel.textAlignment = .center
        noDocLabel.text = "Select a document on the left, or tap the Add Document button above"
        noDocLabel.textColor = .systemGray2
        noDocLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        noDocLabel.numberOfLines = 0
        noDocLabel.translatesAutoresizingMaskIntoConstraints = false
        return noDocLabel
    }()
    
    var documentText: UITextView = {
        let docText = UITextView()
        docText.isEditable = false
        docText.translatesAutoresizingMaskIntoConstraints = false
        docText.font = .preferredFont(forTextStyle: .title2)
        return docText
    }()
    
    private var audioState: AudioState? = .notPlaying
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        guard document != nil else {
            
            view.addSubview(noDocumentLabel)
            
            NSLayoutConstraint.activate([
                noDocumentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                noDocumentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                noDocumentLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.70),
                
                noDocumentLabel.heightAnchor.constraint(equalToConstant: 100)
            ])
            
            return
        }
        
        documentAttributedText = NSMutableAttributedString(string: (document?.text)!)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .title3), .foregroundColor: UIColor.label]
        
        self.documentAttributedText?.setAttributes(attributes, range: NSRange(location: 0, length: (self.document?.text!.count)!))
        
        documentText.attributedText = documentAttributedText
        view.addSubview(documentText)
        
        NSLayoutConstraint.activate([
            documentText.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            
            documentText.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            documentText.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            documentText.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
        ])
        
        audioManager = AudioManager(text: document?.text)
        
        if #available(iOS 16.0, *) {
            navigationItem.style = .editor
            navigationItem.renameDelegate = self
        }
        
        navigationItem.title = document?.title
        navigationItem.titleMenuProvider = { suggestedActions in
            
            var children = suggestedActions
            children += [
                
                UIAction(title: self.document!.isStarred ? "Un-Star Document" : "Star Document", subtitle: nil, image: UIImage(systemName: self.document!.isStarred ? "star.slash" : "star.fill"), identifier: .none, discoverabilityTitle: "Star this document",  attributes: [], state: .off) { _ in
                    
                    let newStatus: Bool = !self.document!.isStarred
                    self.document?.updateDocumentStarredStatus(isStarred: newStatus)
                },
            ]

            return UIMenu(children: children)
        }
        
        let copyTextButton = UIBarButtonItem(title: "Copy Text", image: UIImage(systemName: "doc.on.doc"), target: self, action: #selector(copyText))
        
        audioMenu = UIBarButtonItem(
            image: UIImage(systemName: "waveform.circle"),
            primaryAction: nil,
            menu: returnAudioMenu()
        )
        
        navigationItem.rightBarButtonItems = [copyTextButton, audioMenu]
        navigationItem.hidesBackButton = true
        
        audioManager?.returnRange = { range in

            if self.shouldHighlightCurrentWord == true {
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.documentText.font!.pointSize, weight:.semibold)]
                
                self.documentAttributedText?.setAttributes(attributes, range: range)
                
                let newattributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.documentText.font!.pointSize, weight:.regular)]
                
                self.documentAttributedText?.setAttributes(newattributes, range: NSRange(location: 0, length: range.lowerBound))
                
                self.documentText.attributedText = self.documentAttributedText
            }
        }
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = document?.text
    }

    @objc func playAudio() {
        switch  self.audioState {
            case .notPlaying:
            self.audioManager?.speed = UserDefaults.standard.float(forKey: "speed")
            self.audioManager?.volume = UserDefaults.standard.float(forKey: "volume")
            self.audioManager?.pitch = UserDefaults.standard.float(forKey: "pitch")
            self.audioManager?.startSpeakingText()
            self.audioState = .playing
        case .playing:
            self.audioManager?.pauseText()
            self.audioState = .paused
        case .paused:
            self.audioManager?.continueSpeakingText()
            self.audioState = .playing
        default:
            self.audioManager?.stopSpeakingText()
        }
    }
    
    @objc func openAudioSettingsView() {
        let vc = SoundSettingsViewController()
        let navController = UINavigationController(rootViewController: vc)
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                vc.audioManager = self.audioManager
                if let sheet = navController.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.largestUndimmedDetentIdentifier = .medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersGrabberVisible = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                }
                self.present(navController, animated: true, completion: nil)
            case .pad:
                navController.modalPresentationStyle = UIModalPresentationStyle.popover
                navController.preferredContentSize = CGSize(width: 350, height: 400)
            navController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[1]
                 self.present(navController, animated: true, completion: nil)
        case .mac:
            print("not supported yet")
        default:
            print("error")
        }
    }
    
    func returnAudioMenu() -> UIMenu {
        
        let playPauseAction = UIAction(title:  self.audioState!.text, image:  self.audioState?.icon, identifier: .none, discoverabilityTitle: "Play Document Text", attributes: [], state: .off, handler: { _ in
           
            self.playAudio()
            self.audioMenu.menu = self.returnAudioMenu()
        })
        
        let audioSettingsAction = UIAction(title: "Audio Settings", image: UIImage(systemName: "gear"), identifier: .none, discoverabilityTitle: "Play Document Text", attributes: [], state: .off, handler: { _ in
            
            self.openAudioSettingsView()
        })
        
        let highlightCurrentWord = UIAction(title: "Highlight Current Word", image: UIImage(systemName: "123.rectangle"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: shouldHighlightCurrentWord ? .on : .off, handler: { _ in
            
            self.shouldHighlightCurrentWord.toggle()
            self.audioMenu.menu = self.returnAudioMenu()
        })
        
        let highlightWordsMenu = UIMenu(options: [.singleSelection, .displayInline], children: [highlightCurrentWord])
        
        return UIMenu(options: [], children: [playPauseAction, audioSettingsAction, highlightWordsMenu])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if navigationController == nil {
            audioManager?.stopSpeakingText()
            audioManager = nil
            document = nil
        }
    }
    
    @objc func shareText() {
        let shareImage = ShareableImage(image: UIImage(data: (document?.thumbnail)!)!, title: (document?.title)!, subtitle: "Game screenshot")
        let shareVC = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        present(shareVC, animated: true)
    }
}
