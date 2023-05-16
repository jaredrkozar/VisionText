//
//  AudioSettingsCell.swift
//  VisionText
//
//  Created by Jared Kozar on 4/11/23.
//

import UIKit

class AudioSettingsCell: UITableViewCell {

    static let identifier = "AudioSettingsCell"
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(didChangeSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    private var icon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = .label
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var title: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2, compatibleWith: .current)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private var pickerButton: UIButton = {
        let button = UIButton(configuration: .tinted())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5.0
        return button
    }()
    
    var pickerOptions: [Float]?
    var sliderMaxValue: Float?
    var sliderMinValue: Float? = 0.5
    var text: String? = ""
    var image: UIImage?
    var selectedOption: ((_ value: Float)->())?
    var currentValue: Float?
    
    override func layoutIfNeeded() {
        // Initialization code

        pickerButton.setTitle(currentValue?.description, for: .normal)
        icon.image = image
        title.text = text
        pickerButton.menu = returnMenu()
        slider.value = currentValue!
        slider.minimumValue = sliderMinValue!
       slider.maximumValue = sliderMaxValue!
        pickerButton.showsMenuAsPrimaryAction = true

        contentView.backgroundColor = .secondarySystemGroupedBackground

        self.addSubview(title)
        self.addSubview(slider)
        self.addSubview(icon)
        self.addSubview(pickerButton)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 30),
            icon.heightAnchor.constraint(equalToConstant: 30),
            
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            title.topAnchor.constraint(equalTo: icon.topAnchor),
            title.widthAnchor.constraint(equalToConstant: 200),
            title.heightAnchor.constraint(equalToConstant: 30),
            
            slider.leadingAnchor.constraint(equalTo: icon.leadingAnchor),
            slider.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 25),
            slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            slider.heightAnchor.constraint(equalToConstant: 10),
            
            pickerButton.topAnchor.constraint(equalTo: icon.topAnchor),
            pickerButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            pickerButton.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 10),
            pickerButton.widthAnchor.constraint(equalToConstant: 75),
            
        ])
    }
    override func layoutSubviews() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier )

       
    }
    
    func returnMenu() -> UIMenu {

        var children = [UIAction]()
        for option in pickerOptions! {
            children.append(UIAction(title: "\(option)x", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .on, handler: { _ in
                self.pickerButton.setTitle("\( option)", for: .normal)
                self.slider.value = Float(option)
                self.selectedOption!(Float(option))

            }))
        }
        
        return UIMenu(title: "", image: nil, identifier: nil, options: .singleSelection, children: children)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func didChangeSlider(_ sender: UISlider) {
        let string = round(sender.value * 100) / 100
        self.pickerButton.setTitle("\(string)", for: .normal)
        selectedOption!(string)
    }
}
