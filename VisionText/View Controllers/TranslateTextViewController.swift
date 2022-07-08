//
//  TranslateTextViewController.swift
//  VisionText
//
//  Created by JaredKozar on 7/6/22.
//

import UIKit

class TranslateTextViewController: UIViewController {

    let languageSegmentControl = UISegmentedControl(items: ["Original Text", "Translated Text"])
    
    let originalLanguageButton = UIButton()
    
    let translatedLanguage = UIButton(type: .system)
    
    let textView = UITextView()
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        title = "Translate Text"
        languageSegmentControl.addTarget(self, action: #selector(languageSegmentControlChanged(_:)), for: .valueChanged)
        textView.text = ",.lwkmsx,lskmslrlkjflk,dlk,;lked,x.zs;ld,.;slek,d.x;slk,.xzlkw,ms.;lak,sd.xlskmw s.lksam,sldkm.sd,mxs;lw,s.x.,"
        textView.backgroundColor = .red
        textView.translatesAutoresizingMaskIntoConstraints = false
        languageSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        originalLanguageButton.setTitle("Select Original Language", for: .normal)
        view.addSubview(textView)
        view.addSubview(languageSegmentControl)
        view.addSubview(originalLanguageButton)
        view.addSubview(translatedLanguage)
        
        NSLayoutConstraint.activate([
            
            languageSegmentControl.heightAnchor.constraint(equalToConstant: 40),
            languageSegmentControl.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            languageSegmentControl.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor, constant: 30),
            languageSegmentControl.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: 10),
            
            
            textView.heightAnchor.constraint(equalToConstant: view.bounds.height),
            textView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            textView.topAnchor.constraint(equalTo: originalLanguageButton.bottomAnchor, constant: 60),
            textView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
    
            
            originalLanguageButton.heightAnchor.constraint(equalToConstant: 20),
            originalLanguageButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            originalLanguageButton.topAnchor.constraint(equalTo: languageSegmentControl.bottomAnchor, constant: 20),
            originalLanguageButton.widthAnchor.constraint(equalToConstant: 40),
            
        ])
    }
    
    @objc func languageSegmentControlChanged(_ sender: UISegmentedControl) {
        if languageSegmentControl.selectedSegmentIndex == 0 {
            print("DLDLDL")
        }
    }
}
