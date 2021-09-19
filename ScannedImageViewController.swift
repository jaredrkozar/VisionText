//
//  ScannedImageViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit
import LinkPresentation

class ScannedImageViewController: UIViewController {
    var documentDetails = [Documents]()
    var titleDoc: String = ""
    let recognizeTextButton = UIButton(type: .roundedRect)
    var newimage: UIImage? = nil 
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.navigationItem.setHidesBackButton(false, animated: true)
            case .pad:
                self.navigationItem.setHidesBackButton(true, animated: true)
            default:
                break
        }
        
        view.backgroundColor = UIColor.systemBackground
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        imageView = UIImageView(image: image.downsizeImage(compression: 0.9, dimensions: CGSize(width: view.bounds.width - 200, height: view.bounds.height - 400)))
        
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),  style: .plain, target: self, action: #selector(shareButtonTapped))
        shareButton.accessibilityLabel = "Share Document"
        navigationItem.rightBarButtonItem = shareButton
       
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 157.5),
            imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 194),
            imageView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 210),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 75),
           ])
        
        if image != nil {
            recognizeTextButton.isEnabled = true
        }
        
        #if targetEnvironment(macCatalyst)
        recognizeTextButton.isHidden = true

        #endif
        
        title = "\(titleDoc)"
        setupRecognizeTextButton()
    }
    
    func setupRecognizeTextButton() {
        recognizeTextButton.translatesAutoresizingMaskIntoConstraints = false
        recognizeTextButton.setTitle("Recognize Text", for: .normal)
        recognizeTextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        recognizeTextButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        
        view.addSubview(recognizeTextButton)
        
        NSLayoutConstraint.activate([
            recognizeTextButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -30),
            recognizeTextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           ])
        
        recognizeTextButton.addTarget(self, action: #selector(didTapRecognizeTextButton), for: .touchUpInside)
    }
    
    @objc func didTapRecognizeTextButton() {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone, .pad:
                let vc = recognizedTextViewController()
                         let navigationController = UINavigationController(rootViewController: vc)

               present(navigationController, animated: true, completion: nil)
        case .mac:
            
            let activity = NSUserActivity(activityType: "recognizedText")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
                print(error)
            }

            default:
                break
        }
    }
    
    @objc func shareButtonTapped() {
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
      switch UIDevice.current.userInterfaceIdiom {

          case .mac:
          navigationController?.setNavigationBarHidden(true, animated: animated)
          default:
                  break
          }
        
    }
}
