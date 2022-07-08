//
//  AudioSettingsView.swift
//  VisionText
//
//  Created by JaredKozar on 7/6/22.
//

import UIKit

class AudioSettingsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray5
        
        self.layer.cornerRadius = 9.0
        
        let settingsButton = UIButton(type: .system)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.addTarget(self,
                                 action: #selector(settingsButtonTapped),
                                 for: .touchUpInside)
        self.addSubview(settingsButton)
        
        let highlightWordButton = UIButton(type: .system)
        highlightWordButton.translatesAutoresizingMaskIntoConstraints = false
        highlightWordButton.setImage(UIImage(systemName: "character.bubble"), for: .normal)
        highlightWordButton.addTarget(self,
                                 action: #selector(highlightWordButtonTapped),
                                 for: .touchUpInside)
        self.addSubview(highlightWordButton)
        
        let progressBar = UISlider()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            settingsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            progressBar.trailingAnchor.constraint(equalTo: highlightWordButton.leadingAnchor, constant: -15),
            progressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
        ])
        
        NSLayoutConstraint.activate([
            highlightWordButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            highlightWordButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -15),
            highlightWordButton.leadingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: 15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func settingsButtonTapped(_ sender: UIButton) {
        let vc = SoundSettingsViewController()
                let navigationController = UINavigationController(rootViewController: vc)
                  
                switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        if let picker = navigationController.presentationController as? UISheetPresentationController {
                        picker.detents = [.medium()]
                        picker.prefersGrabberVisible = true
                        picker.preferredCornerRadius = 5.0
                        }
                    self.parentViewController?.present(navigationController, animated: true, completion: nil)
                    case .pad:
                        
                        navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
                        navigationController.preferredContentSize = CGSize(width: 350, height: 225)
                    self.parentViewController?.present(navigationController, animated: true)
                    case .mac:
                        let activity = NSUserActivity(activityType: "soundSettings")
                        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                            print(error)
                        }
                    default:
                            break
                    }
                       
                let popoverPresentationController = vc.popoverPresentationController
        popoverPresentationController?.sourceView = sender
                 
    }
    
    @objc func highlightWordButtonTapped(_ sender: UIButton) {
        var highlightWords: Bool = false
        print(highlightWords)
        if UserDefaults.standard.bool(forKey: "highlightWords") == true {
            sender.backgroundColor = nil
            sender.tintColor = .systemBlue
            let scannedImageVC = self.parentViewController as? ScannedImageViewController
            scannedImageVC?.highlightWords = false
            UserDefaults.standard.set(scannedImageVC?.highlightWords, forKey: "highlightWords")
        } else {
            sender.backgroundColor = .systemBlue
            sender.layer.cornerRadius = 6.0
            sender.tintColor = .systemGray5
            let scannedImageVC = self.parentViewController as? ScannedImageViewController
            scannedImageVC?.highlightWords = true
            UserDefaults.standard.set(scannedImageVC?.highlightWords, forKey: "highlightWords")
        }
    }
}
