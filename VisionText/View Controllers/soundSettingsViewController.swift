//
//  SoundSettingsViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/11/21.
//

import UIKit

class SoundSettingsViewController: UIViewController {
    
    var speedText = UILabel()
    var speedValButton = UIButton(type: .system)
    var speed: Double = 0
    
    var pitchText = UILabel()
    var pitchValButton = UIButton(type: .system)
    var pitch: Double = 0
    
    var volumeText = UILabel()
    let volumeSlider = UISlider()
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        // Do any additional setup after loading the view.
        title = "Sound Settings"
        addSpeedMenu()
        addSpeedLabel()
        addPitchButton()
        addPitchLabel()
        addVolumeLabel()
        addVolumeSlider()
        
        let speed = UserDefaults.standard.double(forKey: "speed")
        
        speedValButton.setTitle(String(speed), for: .normal)
        
        let pitch = UserDefaults.standard.double(forKey: "pitch")
        
        pitchValButton.setTitle(String(pitch), for: .normal)
        
        
        var volumeSliderValue = UserDefaults.standard.double(forKey: "volumeSlider")
        
        if volumeSliderValue == 0.0 {
            volumeSliderValue = 1.0
        }
        volumeSlider.value = Float(volumeSliderValue)
    }
    
    func addSpeedLabel() {
        speedText.text = "Speed"
        speedText.frame = CGRect(x: 20, y: 80, width: 85, height: 27)
        speedText.font = UIFont.preferredFont(forTextStyle: .title3)
        speedText.adjustsFontForContentSizeCategory = true
        view.addSubview(speedText)
    }
    
    func addSpeedMenu() {
        
        view.addSubview(speedValButton)
        
        switch UIDevice.current.userInterfaceIdiom {

            case .phone, .pad:
                speedValButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            default:
                    break
        }
        
        speedValButton.frame = CGRect(x: 160, y: 80, width: 100, height: 32)

        var speeds: [UIAction] {
            return [
                UIAction(title: "0.5x", image:nil, handler: { (_) in
                self.setSpeed(speed: 0.5)
                }),
                
                UIAction(title: "0.75x", image:nil, handler: { (_) in
                self.setSpeed(speed: 0.75)

                }),
                
                UIAction(title: "1x", image:nil, handler: { (_) in
                self.setSpeed(speed: 1.0)
                }),
                
                UIAction(title: "1.25x", image: nil, handler: { (_) in
                self.setSpeed(speed: 1.25)
                }),
                
                UIAction(title: "1.50x", image: nil, handler: { (_) in
                self.setSpeed(speed: 1.5)
                }),
                
                UIAction(title: "1.75x", image: nil, handler: { (_) in
                self.setSpeed(speed: 1.75)
                }),
                
                UIAction(title: "2x", image: nil, handler: { (_) in
                self.setSpeed(speed: 2.0)
                }),
            ]
        }

        speedValButton.menu = UIMenu(title: NSLocalizedString("Select Speed", comment: ""), children: speeds)
        
        speedValButton.changesSelectionAsPrimaryAction = true
            speedValButton.showsMenuAsPrimaryAction = true
        
    }


    func setSpeed(speed: Double) {
        
        UserDefaults.standard.set(speed, forKey: "speed")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
    
    func addPitchLabel() {
        pitchText.text = "Pitch"
        pitchText.frame = CGRect(x: 20, y: 145, width: 80, height: 27)
        pitchText.font = UIFont.preferredFont(forTextStyle: .title3)
        pitchText.adjustsFontForContentSizeCategory = true
        view.addSubview(pitchText)
    }

    func addPitchButton() {
        view.addSubview(pitchValButton)
        
        switch UIDevice.current.userInterfaceIdiom {

            case .phone, .pad:
            pitchValButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            default:
                    break
        }
        
        pitchValButton.frame = CGRect(x: 160, y: 220, width: 100, height: 32)

        var pitches: [UIAction] {
            return [
                UIAction(title: "0.5x", image:nil, handler: { (_) in
                self.setPitch(pitch: 0.5)
                }),
                
                UIAction(title: "0.75x", image:nil, handler: { (_) in
                self.setPitch(pitch: 0.75)
                }),
                
                UIAction(title: "1x", image:nil, handler: { (_) in
                self.setPitch(pitch: 1.0)
                }),
                
                UIAction(title: "1.25x", image: nil, handler: { (_) in
                self.setPitch(pitch: 1.25)
                }),
                
                UIAction(title: "1.50x", image: nil, handler: { (_) in
                self.setPitch(pitch: 1.5)
                }),
                
                UIAction(title: "1.75x", image: nil, handler: { (_) in
                self.setPitch(pitch: 1.75)
                }),
                
                UIAction(title: "2x", image: nil, handler: { (_) in
                self.setPitch(pitch: 2.0)
                }),
            ]
        }

        pitchValButton.menu = UIMenu(title: NSLocalizedString("Select Pitch", comment: ""), children: pitches)
        
        pitchValButton.changesSelectionAsPrimaryAction = true
        pitchValButton.showsMenuAsPrimaryAction = true
        
    }

    func setPitch(pitch: Double) {
        
        UserDefaults.standard.set(pitch, forKey: "pitch")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
    
    func addVolumeLabel() {
        volumeText.text = "Volume"
        volumeText.frame = CGRect(x: 20, y: 220, width: 80, height: 27)
        volumeText.font = UIFont.preferredFont(forTextStyle: .title3)
        volumeText.adjustsFontForContentSizeCategory = true
        view.addSubview(volumeText)
    }
    
    func addVolumeSlider() {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.isContinuous = true
        volumeSlider.frame = CGRect(x: 102, y: 220, width: 250, height: 31)
        view.addSubview(volumeSlider)
        volumeSlider.addTarget(self, action: #selector(self.didChangeVolumeSlider(_:)), for: .valueChanged)
    }
    
    @objc func didChangeVolumeSlider(_ sender: UISlider) {
        
        let selectedVolume = Int(volumeSlider.value)
        
        UserDefaults.standard.set(selectedVolume, forKey: "selectedVolume")
        
        UserDefaults.standard.set(volumeSlider.value, forKey: "volumeSlider")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
}
