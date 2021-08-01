//
//  SoundSettingsViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/11/21.
//

import UIKit

class SoundSettingsViewController: UIViewController {
    
    var speedText = UILabel()
    var speedValText = UILabel()
    var speedValStepper = UIStepper()
    var speedValButton = UIButton()
    var pitchText = UILabel()
    var pitchValText = UILabel()
    let pitchValStepper = UIStepper()
    var pitchValButton = UIButton()
    var volumeText = UILabel()
    var volumeValText = UILabel()
    let volumeSlider = UISlider()
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        // Do any additional setup after loading the view.
        title = "Sound Settings"
        addSpeedStepper()
        addSpeedLabel()
        addPitchStepper()
        addPitchLabel()
        addVolumeLabel()
        addVolumeSlider()
        
        var selectedSpeed = UserDefaults.standard.double(forKey: "selectedSpeed")
        
        if selectedSpeed == 0.0 {
            selectedSpeed = 1.0
        }
        
        speedValStepper.value = Double(selectedSpeed)
        speedValText.text = "\(selectedSpeed)x"
        
        var selectedPitch = UserDefaults.standard.double(forKey: "selectedPitch")
        
        if selectedPitch == 0.0 {
            selectedPitch = 1.0
        }
        
        pitchValStepper.value = Double(selectedPitch)
        pitchValText.text = "\((round(100 * selectedPitch) / 100) / 2)"
        
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
        speedValText.frame = CGRect(x: 140, y: 80, width: 80, height: 27)
        speedValText.font = UIFont.preferredFont(forTextStyle: .title3)
        speedValText.adjustsFontForContentSizeCategory = true
        view.addSubview(speedValText)
    }
    
    func addSpeedStepper() {
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone, .pad:
            
                view.addSubview(speedValStepper)
                speedValStepper.maximumValue = 2.0
                speedValStepper.minimumValue = 0.5
                speedValStepper.stepValue = 0.25
                speedValStepper.autorepeat = true
                speedValStepper.frame = CGRect(x: 264, y: 80, width: 94, height: 32)
                speedValStepper.addTarget(self, action: #selector(didChangeSpeedVal(_:)), for: .valueChanged)


            case .mac:
                
                view.addSubview(speedValButton)
                speedValStepper.frame = CGRect(x: 264, y: 80, width: 94, height: 32)
            
                
                let items = (1...5).map {
                    UIAction(title: String(format: NSLocalizedString("ItemTitle", comment: ""), $0.description), handler: menuHandler)
                }
                speedValButton.menu = UIMenu(title: NSLocalizedString("ChooseItemTitle", comment: ""), children: items)
            speedValButton.changesSelectionAsPrimaryAction = true
                speedValButton.showsMenuAsPrimaryAction = true

            default:
                break
        }
    }
        
func menuHandler(action: UIAction) {
        Swift.debugPrint("Menu Action '\(action.title)'")
    }

    @objc func didChangeSpeedVal(_ sender: UIStepper!) {
        
        let selectedSpeed = Double(speedValStepper.value)
               
        speedValText.text = "\(selectedSpeed)x"
        
        UserDefaults.standard.set(selectedSpeed, forKey: "selectedSpeed")
        
        UserDefaults.standard.set(speedValStepper.value, forKey: "speedValStepper")
        
        NotificationCenter.default.post(name: Notification.Name( "speedChanged"), object: nil)

    }
    
    
    func addPitchLabel() {
        pitchText.text = "Pitch"
        pitchText.frame = CGRect(x: 20, y: 145, width: 80, height: 27)
        pitchText.font = UIFont.preferredFont(forTextStyle: .title3)
        pitchText.adjustsFontForContentSizeCategory = true
        view.addSubview(pitchText)
        pitchValText.frame = CGRect(x: 140, y: 145, width: 80, height: 27)
        pitchValText.font = UIFont.preferredFont(forTextStyle: .title3)
        pitchValText.adjustsFontForContentSizeCategory = true
        view.addSubview(pitchValText)
    }

    func addPitchStepper() {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone, .pad:
                view.addSubview(pitchValStepper)
                pitchValStepper.maximumValue = 2.0
                pitchValStepper.minimumValue = 0.5
                pitchValStepper.stepValue = 0.25
                pitchValStepper.autorepeat = true
                pitchValStepper.frame = CGRect(x: 264, y: 145, width: 94, height: 32)
                pitchValStepper.addTarget(self, action: #selector(didChangePitchVal(_:)), for: .valueChanged)
            
        case .mac:
         
           print("Rrur")

        default:
            break
    }
    }

    @objc func didChangePitchVal(_ sender: UIStepper!) {
        
        let selectedPitch = Double(pitchValStepper.value)
       
        pitchValText.text = "\((round(100 * selectedPitch) / 100) / 2)"
        
        UserDefaults.standard.set(selectedPitch, forKey: "selectedPitch")
        
        UserDefaults.standard.set(pitchValStepper.value, forKey: "pitchValStepper")
        
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
        volumeSlider.frame = CGRect(x: 152, y: 220, width: 199, height: 31)
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
