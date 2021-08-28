//
//  ViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit
import VisionKit
import Vision
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

class AllDocsViewController: UITableViewController, VNDocumentCameraViewControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate, UITableViewDropDelegate {
    
    var sourcesArray = [UIImage]()
    var documentDetails = [Documents]()
    var sortButton = UIButton()
    var sortMethod: String = ""
    var sourceType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        documentDetails = documentDetails.load()
        
        setUpTableView()
        
        title = "All Documents"
        
        let nib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DocumentTableViewCell")

        let addDocButton = Buttons().addDoc()
        addDocButton.accessibilityLabel = "Add Document"
        
        let sortButton = Buttons().sortButton()
        sortButton.accessibilityLabel = "Sort Documents"
        
        navigationItem.rightBarButtonItems = [addDocButton, sortButton]
        
        NotificationCenter.default.addObserver(self, selector: #selector(addImage(_:)), name: NSNotification.Name( "addImage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedsortType(_:)), name: NSNotification.Name( "changedsortType"), object: nil)
    }
    
    @objc func addImage(_ notification: Notification) {

        if sourceTyper == "Scan Document" {
            print("FFF")
            presentDocumentScanner()
        } else if sourceTyper == "Camera" {
            presentCamera()
        } else if sourceTyper == "Photo Library" {
            presentPhotoPicker()
        } else if sourceTyper == "Files" {
            presentFilesPicker()
        } else if sourceTyper == "URL" {
            presentURLPicker()
        }
    }
    
    @objc func changedsortType(_ notification: Notification) {

        if sortMethod == "A-Z" {
            sortDocsbyAZ()
        } else if sortMethod == "Z-A" {
            sortDocsByZA()
        } else if sortMethod == "DateAscending" {
            sortDocsbyDateAscending()
        } else if sortMethod == "DateDescending" {
            sortDocsbyDateDescending()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
        
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
     //handles drops
        
      let destinationIndexPath: IndexPath

      if let indexPath = coordinator.destinationIndexPath {
          destinationIndexPath = indexPath
      } else {
          let section = tableView.numberOfSections - 1
          let row = tableView.numberOfRows(inSection: section)
          destinationIndexPath = IndexPath(row: row, section: section)
      }
      
      // attempt to load strings from the drop coordinator
      coordinator.session.loadObjects(ofClass: UIImage.self) { items in
          // convert the item provider array to a string array or bail out
          guard let strings = items as? [UIImage] else { return }

          // create an empty array to track rows we've copied
          var indexPaths = [IndexPath]()

          // loop over all the strings we received
          for (index, image) in strings.enumerated() {
              // create an index path for this new row, moving it down depending on how many we've already inserted
              let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)

              self.sourcesArray.append(image)
              self.presentAlert(sourcesArray: self.sourcesArray)

          }
      }
    }
    
    @objc func sortDocsbyAZ() {
        self.documentDetails = self.documentDetails.sorted(by: { $0.name < $1.name })
            self.tableView.reloadData()
    }
    
    @objc func sortDocsByZA() {
        self.documentDetails = self.documentDetails.sorted(by: { $0.name > $1.name })
            self.tableView.reloadData()
    }
    
    @objc func sortDocsbyDateAscending() {
        self.documentDetails = self.documentDetails.sorted(by: { $0.date < $1.date })
            self.tableView.reloadData()
    }
    
    @objc func sortDocsbyDateDescending() {
        self.documentDetails = self.documentDetails.sorted(by: { $0.date > $1.date })
            self.tableView.reloadData()
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = 167
        tableView.dropDelegate = self
    }
    
    @objc func presentURLPicker() {
        self.sourcesArray.removeAll()
        
        let enterURL = UIAlertController(title: "Enter URL", message: "Enter the direct URL of the image you want to get the text from.", preferredStyle: .alert)
    
        enterURL.addTextField()
        
        enterURL.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        enterURL.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak enterURL] _ in

            let textField = enterURL?.textFields![0]
                    
            let url = URL(string: (textField?.text)!)

            if UIApplication.shared.canOpenURL(url! as URL) == true {
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.sourcesArray.append(image)
                                
                                self!.presentAlert(sourcesArray: self!.sourcesArray)
                                
                            }
                        }
                    }
                }
            } else {
                let invalidURL = UIAlertController(title: "Invalid URL", message: "The direct image URL you entered is invalid. Please enter another URL.", preferredStyle: .alert)
                
                invalidURL.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self!.present(invalidURL, animated: true)
            }
        })
        present(enterURL, animated: true)
    }
    
    @objc func presentFilesPicker() {
        self.sourcesArray.removeAll()
        let documentpicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        documentpicker.delegate = self
            self.present(documentpicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else {
            return
        }
        
        myURL.startAccessingSecurityScopedResource()
        do {
            let imageData = try Data(contentsOf: myURL)
            let image = UIImage(data: imageData)!
            sourcesArray.append(image)
        } catch {
            print("There was an error loading the image: \(error). Please try again.")
        }
        
        myURL.startAccessingSecurityScopedResource()
        presentAlert(sourcesArray: sourcesArray)
        
    }
    
    @objc func presentCamera() {
        self.sourcesArray.removeAll()

        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            guard let image = info[.editedImage] as? UIImage else {
                print("No image was found at this location. Please try again.")
                return
            }

            sourcesArray.append(image)
            dismiss(animated: true, completion: nil)
            presentAlert(sourcesArray: sourcesArray)
    }
    
    @objc func presentPhotoPicker() {
        self.sourcesArray.removeAll()
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage else { return }
                    
                    self.sourcesArray.append(image)
                    self.presentAlert(sourcesArray: self.sourcesArray)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    
    @objc func presentDocumentScanner() {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        let errorAlert = UIAlertController(title: "Failed to scan document", message: "The document couldn't be scanned right now. Please try again.", preferredStyle: .alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(errorAlert, animated: true)
        
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller:            VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Process the scanned pages
        
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            
            sourcesArray.append(image)
        }
        
        controller.dismiss(animated: true)
        print("Finished scanning document \(kCGPDFContextTitle)")
        presentAlert(sourcesArray: sourcesArray)
    }

    func presentAlert(sourcesArray: [UIImage]) {
        let ac = UIAlertController(title: "Name Document", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
                    
            let currentDate = self!.getCurrentShortDate()
            let uuid = UUID().uuidString
                        
            let thumbnailasString = self?.sourcesArray[0].converttoString()
            let document = Documents(thumbnail:  thumbnailasString!, name: (textField?.text)!, date: currentDate, isStarred: false, uuid: uuid)
            self!.documentDetails.append(document)
        
            self!.documentDetails.save()
            self!.tableView.reloadData()
            
        })
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let document = documentDetails[indexPath.row]

        cell.documentName.text = document.name

        cell.documentThumbnail.image = document.thumbnail.toImage()?.downsizeImage(compression: 0.25, dimensions: CGSize(width: 109, height: 142))

        cell.documentDate.text = document.date
        cell.accessibilityLabel = "\(document.name) Created on \(document.date)"
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func getCurrentShortDate() -> String {
        let todaysDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy, h:mm a"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)

        return DateInFormat
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "row")
        let document = documentDetails[indexPath.row]
        let vc = ScannedImageViewController()

        let documentCell = tableView.cellForRow(at: indexPath) as! DocumentTableViewCell
        documentCell.documentName.textColor = UIColor.tertiaryLabel
        documentCell.documentDate.textColor = UIColor.tertiaryLabel
        
        vc.titleDoc = document.name
        vc.scannedImage = document.thumbnail
        splitViewController?.setViewController(ScannedImageViewController(), for: .secondary)
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                navigationController?.pushViewController(vc, animated: true)
        case .pad, .mac:
                showDetailViewController(vc, sender: true)

            default:
                break
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let documentCell = tableView.cellForRow(at: indexPath) as! DocumentTableViewCell
        documentCell.documentName.textColor = UIColor.label
        documentCell.documentDate.textColor = UIColor.secondaryLabel

    }
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let document = documentDetails[indexPath.row]
        //saves the row the user bought the context menu appear on in row
        let row = indexPath.row
        
        UserDefaults.standard.set(row, forKey: "row")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let starAction = UIAction(title: "Star", image: UIImage(systemName: "star")) { [self] _ in
    
                starDocument(indexPath: indexPath)
            }
            
            let unstarAction = UIAction(title: "Unstar", image: UIImage(systemName: "star.fill")) { [self] _ in
                unstarDocument(indexPath: indexPath)
            }
            
            let deleteAction = UIAction(
                //deletes the current cell
              title: "Delete",
              image: UIImage(systemName: "trash"),
                attributes: .destructive) { [self] _ in
                
                deleteDocument(tableView, indexPath: indexPath)
            }
                
            let renameAction = UIAction(
                //deletes the current cell
              title: "Rename",
              image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { [self] _ in
                
                renameDocument(tableView, indexPath: indexPath)
            }
            
            if document.isStarred == true {
                           return UIMenu(title: "", children: [renameAction, unstarAction, deleteAction])
                       } else {
                           return UIMenu(title: "", children: [renameAction, starAction, deleteAction])
                       }
        }
    }
    
    func deleteDocument(_ tableView: UITableView, indexPath: IndexPath) {
        
        documentDetails.remove(at: indexPath.row)
        tableView.reloadData()
        DispatchQueue.global(qos: .userInitiated).async {
            self.documentDetails.save()
        }
    }
    
    func starDocument(indexPath: IndexPath) {
        let document = documentDetails[indexPath.row]
        document.isStarred = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.documentDetails.save()
        }
    }
    
    func unstarDocument(indexPath: IndexPath) {
        let documents = documentDetails[indexPath.row]
        documents.isStarred = false
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.documentDetails.save()
        }
    }
    
    
    func renameDocument(_ tableView: UITableView, indexPath: IndexPath) {

        let ac = UIAlertController(title: "Rename Document", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
            self!.documentDetails[indexPath.row].name = (textField?.text)!
            self!.documentDetails.save()
            self!.tableView.reloadData()
            
        })
        present(ac, animated: true)
    }
}
