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
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            settingsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
        
        let progressBar = UISlider()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            progressBar.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -15),
            progressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
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
}
