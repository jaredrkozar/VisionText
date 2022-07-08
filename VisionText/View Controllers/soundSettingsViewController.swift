//
//  SoundSettingsViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/11/21.
//

import UIKit

class SoundSettingsViewController: UIViewController {
    
    var speedText: UILabel {
        var speedlabel = UILabel()
        speedlabel.text = "Speed"
        speedlabel.frame = CGRect(x: 20, y: 80, width: 85, height: 27)
        speedlabel.font = UIFont.preferredFont(forTextStyle: .title3)
        speedlabel.adjustsFontForContentSizeCategory = true
        return speedlabel
    }
    var speedValButton = UIButton(type: .system)

    
    var pitchText: UILabel {
        var pitchlabel = UILabel()
        pitchlabel.text = "Pitch"
        pitchlabel.frame = CGRect(x: 20, y: 145, width: 80, height: 27)
        pitchlabel.font = UIFont.preferredFont(forTextStyle: .title3)
        pitchlabel.adjustsFontForContentSizeCategory = true
        return pitchlabel
    }
    
    var pitchValButton = UIButton(type: .system)
    
    var volumeText: UILabel {
        let volumelabel = UILabel()
        volumelabel.text = "Volume"
        volumelabel.frame = CGRect(x: 20, y: 220, width: 80, height: 27)
        volumelabel.font = UIFont.preferredFont(forTextStyle: .title3)
        volumelabel.adjustsFontForContentSizeCategory = true
        return volumelabel
    }
    
    let volumeSlider = UISlider()
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        // Do any additional setup after loading the view.
        title = "Sound Settings"
        
        view.addSubview(speedText)
        view.addSubview(pitchText)
        view.addSubview(volumeText)
        
        addSpeedMenu()

        addPitchButton()
        
        addVolumeSlider()
        
        let speed = UserDefaults.standard.double(forKey: "speed")
        
        speedValButton.setTitle(String("\(speed * 2)x"), for: .normal)
        
        let pitch = UserDefaults.standard.double(forKey: "pitch")
        
        pitchValButton.setTitle(String(pitch), for: .normal)
        volumeSlider.value = UserDefaults.standard.float(forKey: "volume")
    }
    
    func addSpeedMenu() {
        
        view.addSubview(speedValButton)
        
        switch UIDevice.current.userInterfaceIdiom {

            case .phone, .pad:
                speedValButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            default:
                    break
        }
        
        speedValButton.frame = CGRect(x: 250, y: 80, width: 100, height: 32)

        var speeds = [UIAction]()
        
        for speed in listofeffects.allCases {
           speeds.append( UIAction(title: "\(speed.rawValue)x", image: nil, identifier: nil, attributes: []) { _ in
               self.setSpeed(speed: speed.rawValue)
           })
        }

        speedValButton.menu = UIMenu(title: NSLocalizedString("Select Speed", comment: ""), children: speeds)
        
        speedValButton.changesSelectionAsPrimaryAction = true
            speedValButton.showsMenuAsPrimaryAction = true
        
    }

    func setSpeed(speed: Double) {
        
        UserDefaults.standard.set(speed / 2, forKey: "speed")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
    
    func addPitchButton() {
        view.addSubview(pitchValButton)
        
        switch UIDevice.current.userInterfaceIdiom {

            case .phone, .pad:
            pitchValButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            default:
                    break
        }
        
        pitchValButton.frame = CGRect(x: 250, y: 145, width: 100, height: 32)
        
        var pitches = [UIAction]()
        
        for speed in listofeffects.allCases {
           pitches.append( UIAction(title: "\(speed.rawValue)", image: nil, identifier: nil, attributes: []) { _ in
               self.setPitch(pitch: speed.rawValue)
           })
        }

        pitchValButton.menu = UIMenu(title: NSLocalizedString("Select Pitch", comment: ""), children: pitches)
        
        pitchValButton.changesSelectionAsPrimaryAction = true
        pitchValButton.showsMenuAsPrimaryAction = true
        
    }

    func setPitch(pitch: Double) {
        
        UserDefaults.standard.set(pitch, forKey: "pitch")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
    
    func addVolumeSlider() {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.isContinuous = true
        volumeSlider.frame = CGRect(x: 150, y: 220, width: 180, height: 31)
        view.addSubview(volumeSlider)
        volumeSlider.addTarget(self, action: #selector(self.didChangeVolumeSlider(_:)), for: .valueChanged)
    }
    
    @objc func didChangeVolumeSlider(_ sender: UISlider) {
        
        let selectedVolume = Int(volumeSlider.value)
        
        UserDefaults.standard.set(volumeSlider.value, forKey: "volume")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)
    }
}
