//
//  recognizedTextViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/10/21.
//

import UIKit
import Vision
import AVFoundation

class recognizedTextViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    let synth = AVSpeechSynthesizer()
    var recognizedText = Buttons().setRecognizedText()
    var textWidth: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        // Do any additional setup after loading the view.
        
        
        recognizedText.translatesAutoresizingMaskIntoConstraints = false
        synth.stopSpeaking(at: .immediate)
        view.addSubview(recognizedText)

        NSLayoutConstraint.activate([
            recognizedText.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            recognizedText.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            recognizedText.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor)
        ])
        
        title = "Recognized Text"
        
        let soundButton = UIBarButtonItem(image: UIImage(systemName: "speaker.wave.3"),  style: .plain, target: self, action: #selector(speakText))
        soundButton.accessibilityLabel = "Speak Text"
        
        let gearButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),  style: .plain, target: self, action: #selector(soundSettings))
        gearButton.accessibilityLabel = "Sound Settings"
        
        let doneButton = UIBarButtonItem(title: "Done",  style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.accessibilityLabel = "Done"
        
        let copyButton = UIBarButtonItem(title: "Copy",  style: .plain, target: self, action: #selector(copyButtonTapped))
        copyButton.accessibilityLabel = "Copy Text"
        
        navigationItem.leftBarButtonItems = [soundButton, gearButton]
        navigationItem.rightBarButtonItems = [doneButton, copyButton]
        
        NotificationCenter.default.addObserver(self, selector: #selector(speedChanged(_:)), name: NSNotification.Name( "speedChanged"), object: nil)
        
        self.navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
        
    }
    
    func viewDidAppear() {
        self.recognizedText.scrollRangeToVisible(NSMakeRange(0, 0))
    }

    
    @objc func copyButtonTapped(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = recognizedText.text
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        synth.stopSpeaking(at: .immediate)
    }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
        synth.stopSpeaking(at: .immediate)
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        synth.stopSpeaking(at: .immediate)

    }
    
    @objc func speakText(_ sender: UIBarButtonItem) {

        if (synth.isPaused) {
            synth.continueSpeaking()
            sender.image = UIImage(systemName: "speaker.wave.3.fill")
        } else if (synth.isSpeaking) {
            synth.pauseSpeaking(at: .immediate)
            sender.image = UIImage(systemName: "speaker.slash.fill")
        } else if (!synth.isSpeaking) {
            NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
            sender.image = UIImage(systemName: "speaker.wave.3.fill")
        }
    }

    func speaktext() -> AVSpeechUtterance {
        let speech = AVSpeechUtterance(string: recognizedText.text!)
        speech.voice = AVSpeechSynthesisVoice(language: "en-US")
        return speech
    }
    
    @objc func speedChanged(_ notification: Notification) {
        synth.stopSpeaking(at: .immediate)
        let speech = speaktext()
        speech.rate = Float((UserDefaults.standard.double(forKey: "speed") / 2))
        speech.pitchMultiplier = Float((UserDefaults.standard.double(forKey: "pitch")))
        speech.volume = Float((UserDefaults.standard.double(forKey:  "volumeSlider")))
        synth.speak(speech)

    }
        
    @objc func soundSettings(_ sender: UIBarButtonItem) {
        let vc = SoundSettingsViewController()
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
                
                navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
                navigationController.preferredContentSize = CGSize(width: 350, height: 225)
            self.present(navigationController, animated: true, completion: nil)
            case .mac:
                let activity = NSUserActivity(activityType: "soundSettings")
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                    print(error)
                }
            default:
                    break
            }
               
        let popoverPresentationController = vc.popoverPresentationController
        popoverPresentationController?.barButtonItem = sender
        
    }
    
}
