//
//  ScannedImageViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import AVFoundation

class RecognizedTextViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    var index: Int?
    var synthesizer = AVSpeechSynthesizer()
    private var highlightCurrentWord: Bool = false
    var currentRange = NSRange(location: 0, length: 0)
    
    var speakingString:String?
    
    let documentText = UITextView(frame: .zero, textContainer: nil)
    
    private var textBoxTopContraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        synthesizer.delegate = self
        
        documentText.translatesAutoresizingMaskIntoConstraints = false
        guard index != nil else {
            view.backgroundColor = .systemBackground
          self.navigationItem.title = nil
          let noNoteLabel = UILabel()
          noNoteLabel.textAlignment = .center
          noNoteLabel.text = "Select a note on the left, or tap the New Note button on the upper right"
          noNoteLabel.textColor = .systemGray2
          noNoteLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
          noNoteLabel.numberOfLines = 0
          noNoteLabel.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(noNoteLabel)
          
          NSLayoutConstraint.activate([
              noNoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

              noNoteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
              
              noNoteLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.70),
              
              noNoteLabel.heightAnchor.constraint(equalToConstant: 600)
          ])
            return
        }
        let mutableAttributedString = NSMutableAttributedString(string: documents[index!].text!)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range:  NSMakeRange(0, (documents[index!].text?.count)!))
        mutableAttributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSMakeRange(0, (documents[index!].text?.count)!))
        
        documentText.attributedText = mutableAttributedString
        documentText.adjustsFontForContentSizeCategory = true
        documentText.isEditable = false
        documentText.isSelectable = true
        self.view.addSubview(documentText)

        textBoxTopContraint = documentText.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor)
        textBoxTopContraint?.isActive = true
        
        NSLayoutConstraint.activate([
            
            documentText.heightAnchor.constraint(equalToConstant: view.bounds.height),
            documentText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
           
            documentText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        highlightCurrentWord = UserDefaults.standard.bool(forKey: "highlightCurrentWord")
        
        let copyText = UIBarButtonItem(image: UIImage(systemName: "doc.text"), style: .plain, target: self, action: #selector(copyDocumentText(_:)))
        
        let speakText = UIBarButtonItem(image: UIImage(systemName: "play.circle"), style: .plain, target: self, action: #selector(speakText(_:)))
        
        let soundOptions = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(showSoundOptions))

        let shareText = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareText))
        
        speakingString = documents[index!].text
        navigationItem.rightBarButtonItems = [copyText, speakText, soundOptions, shareText]
        navigationItem.title = documents[index!].title ?? "Untitled"
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(speedChanged(_:)), name: NSNotification.Name( "speedChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(highlightWord), name: NSNotification.Name( "highlightCurrentWord"), object: nil)
        
        if #available(iOS 16.0, *) {
            navigationItem.titleMenuProvider = { suggestedActions in
                
                var children = suggestedActions
                children += [
                    
                    UIAction(title: documents[self.index!].isStarred ? "Un-Star Document" : "Star Document", subtitle: nil, image: documents[self.index!].isStarred ? UIImage(systemName: "star.slash") : UIImage(systemName: "star"), identifier: .none, discoverabilityTitle: "String? = nil",  attributes: [], state: .off) { _ in
                        
                        updateDocumentStarredStatus(index: self.index!, isStarred: documents[self.index!].isStarred)
                    },
                ]
                
                return UIMenu(children: children)
            }
        } else {
            // Fallback on earlier versions
        }
    
    }
    
    @objc func highlightWord() {
        highlightCurrentWord = !highlightCurrentWord
    }
    
    @objc func shareText(_ sender: AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [documentText.text!], applicationActivities: nil)
          activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
          
          // present the view controller
          self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func showSoundOptions(_ sender: UIBarButtonItem) {
        let vc = SoundSettingsViewController()
        let navigationController = UINavigationController(rootViewController: vc)

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if let picker = navigationController.presentationController as? UISheetPresentationController {
            picker.detents = [.medium()]
            picker.prefersGrabberVisible = true
            picker.preferredCornerRadius = 5.0
            }
            self.parent?.present(navigationController, animated: true, completion: nil)
        case .pad:
            
            navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
            navigationController.preferredContentSize = CGSize(width: 350, height: 225)
            self.parent?.present(navigationController, animated: true)
        case .mac:
            let activity = NSUserActivity(activityType: "soundSettings")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }
        default:
                break
        }
           
        let popoverPresentationController = vc.popoverPresentationController
        if #available(iOS 16.0, *) {
            popoverPresentationController?.sourceItem = sender
        } else {
            popoverPresentationController?.barButtonItem = sender
        }

    }
    override func viewDidDisappear(_ animated: Bool) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
   
        currentRange = characterRange
        
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range:  NSMakeRange(0, (utterance.speechString as NSString).length))
        if highlightCurrentWord == true {
            mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: characterRange)
        }
        
        mutableAttributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range:  NSMakeRange(0, (utterance.speechString as NSString).length))
        
        documentText.attributedText = mutableAttributedString
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        documentText.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    @objc func copyDocumentText(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = documentText.text
     }
    
    @objc func speakText(_ sender: UIBarButtonItem) {

        if synthesizer.isPaused {
            sender.image = UIImage(systemName: "pause.circle")
            synthesizer.continueSpeaking()
        } else if synthesizer.isSpeaking {
            print("PAAUSED")
            sender.image = UIImage(systemName: "play.circle")
            synthesizer.pauseSpeaking(at: .immediate)
        } else {
            sender.image = UIImage(systemName: "pause.circle")
            speakUtterance(text: speakingString!, pitch: UserDefaults.standard.float(forKey: "pitch"), rate: UserDefaults.standard.float(forKey: "speed"), volume: UserDefaults.standard.float(forKey: "volume"))
        }
     }
    
    func speakUtterance(text: String, pitch: Float, rate: Float, volume: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: "en")
        synthesizer.speak(utterance)
    }
    
    @objc func speedChanged(_ notification: Notification) {
        synthesizer.stopSpeaking(at: .immediate)
        speakUtterance(text: speakingString!, pitch: 1.0, rate: UserDefaults.standard.float(forKey: "speed"), volume: UserDefaults.standard.float(forKey: "volume"))
    }
    
    @objc func toggleStar() {
        documents[index!].isStarred.toggle()
    }
}

extension ScannedImageViewController: UINavigationItemRenameDelegate {
    func navigationItem(_: UINavigationItem, didEndRenamingWith title: String) {
        navigationItem.title = title
        updateDocumentTitle(index: index!, title: title)
        NotificationCenter.default.post(name: Notification.Name("reloadNotesTable"), object: nil)
        
    }
}

