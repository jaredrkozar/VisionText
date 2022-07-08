//
//  ScannedImageViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import AVFoundation
class ScannedImageViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    var document: Document?
    
    var isDocStarred: Bool?
    
    var synthesizer = AVSpeechSynthesizer()
    
    var currentRange = NSRange(location: 0, length: 0)
    
    var speakingString:String?
    
    let documentText = UITextView(frame: .zero, textContainer: nil)
    
    var highlightWords: Bool? = false
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        synthesizer.delegate = self
        
        documentText.translatesAutoresizingMaskIntoConstraints = false
        let mutableAttributedString = NSMutableAttributedString(string: (document?.text)!)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range:  NSMakeRange(0, (document?.text!.count)!))
        mutableAttributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSMakeRange(0, (document?.text!.count)!))
        documentText.attributedText = mutableAttributedString
        
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
        
        if document?.text == nil {
            speakText.isEnabled = false
        } else {
            speakingString = document?.text
        }
        
        let translateText = UIBarButtonItem(image: UIImage(systemName: "character.bubble"), style: .plain, target: self, action: #selector(translateText(_:)))
        
        navigationItem.rightBarButtonItems = [copyText, speakText, translateText]
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(speedChanged(_:)), name: NSNotification.Name( "speedChanged"), object: nil)
    
    }
      
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentRange = characterRange
        
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range:  NSMakeRange(0, (utterance.speechString as NSString).length))
        if highlightWords == true {
            mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: characterRange)
        }
        
        mutableAttributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range:  NSMakeRange(0, (utterance.speechString as NSString).length))
        documentText.attributedText = mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        documentText.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    @objc func translateText(_ sender: UIBarButtonItem) {
        let vc = TranslateTextViewController()
                let navigationController = UINavigationController(rootViewController: vc)
                  
                switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        if let picker = navigationController.presentationController as? UISheetPresentationController {
                        picker.detents = [.medium()]
                        picker.prefersGrabberVisible = true
                        picker.preferredCornerRadius = 5.0
                        }
                    self.present(navigationController, animated: true, completion: nil)
                    case .pad:
                    self.present(navigationController, animated: true)
                    case .mac:
                        let activity = NSUserActivity(activityType: "soundSettings")
                        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                            print(error)
                        }
                    default:
                            break
                    }
    }
    @objc func copyDocumentText(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = document?.text
     }
    
    @objc func speakText(_ sender: UIBarButtonItem) {
    
        let settingsView = AudioSettingsView(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.maxY)! ?? 40, width: self.view?.frame.size.width ?? 30, height: (self.navigationController?.navigationBar.frame.height)! ?? 40))
        
        if synthesizer.isPaused {
            print("CONTINUE")
            sender.image = UIImage(systemName: "pause.circle")
            synthesizer.continueSpeaking()
        } else if synthesizer.isSpeaking {
            print("PAAUSED")
            sender.image = UIImage(systemName: "play.circle")
            synthesizer.pauseSpeaking(at: .word)
        } else {
            sender.image = UIImage(systemName: "pause.circle")
            speakUtterance(text: speakingString!, pitch: 1.0, rate: UserDefaults.standard.float(forKey: "speed") ?? 1.0, volume: UserDefaults.standard.float(forKey: "volume"))
            view.addSubview(settingsView)
        }
     }
    
    func speakUtterance(text: String, pitch: Float, rate: Float, volume: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    @objc func speedChanged(_ notification: Notification) {
        synthesizer.stopSpeaking(at: .word)
        if currentRange.length > 0 {
            let startIndex = speakingString!.index(speakingString!.startIndex, offsetBy: NSMaxRange(currentRange))
            let newString = String(speakingString![startIndex...])
            print(newString)
            speakingString = newString
            
            speakUtterance(text: speakingString!, pitch: 1.0, rate: UserDefaults.standard.float(forKey: "speed") ?? 1.0, volume: UserDefaults.standard.float(forKey: "volume"))
      }
    }
}

extension ScannedImageViewController: UINavigationItemRenameDelegate {
    func navigationItem(_: UINavigationItem, didEndRenamingWith title: String) {
        navigationItem.title = title
        updateDocument(document: document!, title: navigationItem.title ?? "Untitled", isStarred: isDocStarred ?? false)
        NotificationCenter.default.post(name: Notification.Name("reloadNotesTable"), object: nil)
        
    }
}

