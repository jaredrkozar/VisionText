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
    
    var newImage: UIImage?
    let synth = AVSpeechSynthesizer()
    var recognizedText = Buttons().setRecognizedText()
    var textWidth: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        // Do any additional setup after loading the view.
        synth.stopSpeaking(at: .immediate)
        view.addSubview(recognizedText)
       
        let guide = view.readableContentGuide
        recognizedText.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        recognizedText.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        recognizedText.heightAnchor.constraint(equalToConstant: recognizedText.contentSize.height).isActive = true
       
        recognizeText(newImage: newImage!)
        
        title = "Recognized Text"
        
        print(view.readableContentGuide)
        print("FFFFFFFFF<F<")
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
            case .pad, .mac:

                navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
                navigationController.preferredContentSize = CGSize(width: 350, height: 225)
            default:
                    break
            }
           
        self.present(navigationController, animated: true, completion: nil)
               
        let popoverPresentationController = vc.popoverPresentationController
        popoverPresentationController?.barButtonItem = sender
        
    }
    
    func recognizeText(newImage: UIImage) {
        guard let cgimage = newImage.cgImage else {
            print("Could not get the image. Please try again")
            return
        }
        
        let textHandler = VNImageRequestHandler(cgImage: cgimage, options: [:])

        let request = VNRecognizeTextRequest { request, error in
            
            let observations = request.results as? [VNRecognizedTextObservation]

            let text = observations?.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")

            DispatchQueue.main.async {
                if text == "" {
                    self.recognizedText.text = "There was no text found in this document. Please check another document and try again."
                } else {
                    self.recognizedText.text = "\(text!)"
                }
            }

        }
        
        do {
            try textHandler.perform([request])
        } catch {
            recognizedText.text = "\(error)"
        }
        
    }
    
}
