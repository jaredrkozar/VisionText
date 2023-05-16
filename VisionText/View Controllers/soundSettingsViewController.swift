//
//  SoundSettingsViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 9/4/22.
//

import UIKit

class SoundSettingsViewController: UITableViewController {
    
    var audioManager: AudioManager?
    
    override func viewDidLoad() {
        title = "Audio Settings"
        self.tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.register(AudioSettingsCell.self, forCellReuseIdentifier: AudioSettingsCell.identifier)
        tableView.rowHeight = 100
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioSettingsCell.identifier, for: indexPath) as? AudioSettingsCell
       
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        
        switch indexPath.section {
            case 0:
                cell?.image = UIImage(systemName: "speedometer", withConfiguration: config)
                cell?.text = "Speed"
            cell?.pickerOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
            cell?.currentValue = UserDefaults.standard.float(forKey: "speed")
            cell?.sliderMinValue = 0.25
            cell?.sliderMaxValue = 2.0
        case 1:
            cell?.image = UIImage(systemName: "speedometer", withConfiguration: config)
            cell?.text = "Pitch"
            cell?.pickerOptions = [0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0]
            cell?.currentValue = UserDefaults.standard.float(forKey: "pitch")
            cell?.sliderMinValue = 0.1
            cell?.sliderMaxValue = 1.0
        case 2:
            cell?.image = UIImage(systemName: "speaker.wave.3", withConfiguration: config)
            cell?.text = "Volume"
            cell?.pickerOptions = [0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0]
            cell?.currentValue = UserDefaults.standard.float(forKey: "volume")
            cell?.sliderMinValue = 0.1
            cell?.sliderMaxValue = 1.0
        default:
            cell?.text = "Error"
            cell?.image = UIImage()
        }
        
        cell?.selectedOption = { value in
            switch indexPath.section {
            case 0:
                UserDefaults.standard.set(value, forKey: "speed")
                self.audioManager?.changeSpeed(newSpeed: value)
            case 1:
                UserDefaults.standard.set(value, forKey: "pitch")
                self.audioManager?.changePitch(newPitch: value)
            case 2:
                UserDefaults.standard.set(value, forKey: "volume")
                self.audioManager?.changeVolume(newVolume: value)
            default:
                return
            }
        }
        return cell!
        
    }
}
