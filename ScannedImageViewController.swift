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
    var scannedImage: String = ""
    var titleDoc: String = ""
    let recognizeTextButton = UIButton(type: .roundedRect)
    var image: UIImage!
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

        if scannedImage != "" {
            imageView = UIImageView(image: scannedImage.toImage()!.downsizeImage(compression: 0.75, dimensions: CGSize(width: view.bounds.width - 200, height: view.bounds.height - 400)))
        }
        
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        let share = UIImage(systemName: "square.and.arrow.up")!
        let shareButton = UIBarButtonItem(image: share,  style: .plain, target: self, action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem = shareButton
       
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 157.5),
            imageView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 194),
            imageView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 210),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 75),
           ])
        
        if scannedImage.toImage() != nil {
            recognizeTextButton.isEnabled = true
        }
        
        #if targetEnvironment(macCatalyst)
        recognizeTextButton.isHidden = true

        #endif
        
        title = "\(titleDoc)"
        setupRecognizeTextButton()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard !scannedImage.isEmpty else { return false }
      return super.canPerformAction(action, withSender: sender)
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
        
        let vc = recognizedTextViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        vc.newImage = scannedImage.toImage()
        
        navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet

        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func shareButtonTapped() {
        
        let vc = UIActivityViewController(activityItems: [scannedImage], applicationActivities: nil)
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
