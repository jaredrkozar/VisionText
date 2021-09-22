//
//  ViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit

class AllDocsViewController: UITableViewController & UINavigationControllerDelegate, UITableViewDropDelegate {
    
    var documentDetails = [Documents]()
    var sortButton = UIButton()
    
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

        if sourceType == "Scan Document" {
            presentDocumentScanner()
        } else if sourceType == "Camera" {
            presentCamera()
        } else if sourceType == "Photo Library" {
            presentPhotoPicker()
        } else if sourceType == "Files" {
            presentFilesPicker()
        } else if sourceType == "URL" {
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

              self.presentAlert(imageToPresent: image)

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

    func presentAlert(imageToPresent: UIImage) {
        let ac = UIAlertController(title: "Name Document", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
                    
            let currentDate = self!.getCurrentShortDate()
            let uuid = UUID().uuidString
                        
            let thumbnailasString = imageToPresent.converttoString()
            let document = Documents(thumbnail:  thumbnailasString, name: (textField?.text)!, date: currentDate, isStarred: false, uuid: uuid)
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
        
        if document.isStarred == true {
            cell.documentStatusImage.image = UIImage(systemName: "star.fill")
        } else {
            cell.documentStatusImage.image = nil
        }
       
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
        
        image = document.thumbnail.toImage()!
        
        splitViewController?.setViewController(ScannedImageViewController(), for: .secondary)
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                navigationController?.pushViewController(vc, animated: true)
        case .pad, .mac:
            splitViewController?.setViewController(ScannedImageViewController(), for: .secondary)
            
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
            
            let title = document.isStarred ?
            "Unstar" :
                "Star"
            let image = document.isStarred ? "star" : "star.fill"
            
            let toggleStarAction = UIAction(title: title, image: UIImage(systemName: "\(image)")) { [self] _ in
    
                toggleStar(indexPath: indexPath)
            }
            
            let deleteAction = UIAction(
                //deletes the current cell
              title: "Delete",
              image: UIImage(systemName: "trash"),
                attributes: .destructive) { [self] _ in
                
                deleteDocument(tableView, indexPath: indexPath)

            }
                
            let renameAction = UIAction(
                //renames the document in the current cell
              title: "Rename",
              image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { [self] _ in
                
                renameDocument(tableView, indexPath: indexPath)
            }
            
            return UIMenu(title: "", children: [renameAction, toggleStarAction, deleteAction])
        }
    }
    
    func deleteDocument(_ tableView: UITableView, indexPath: IndexPath) {
        documentDetails.remove(at: indexPath.row)
       
        tableView.reloadData()
        DispatchQueue.global(qos: .userInitiated).async {
            self.documentDetails.save()
        }
    }
    
    func toggleStar(indexPath: IndexPath) {
        let document = documentDetails[indexPath.row]
        document.isStarred.toggle()
        
        DispatchQueue.global(qos: .userInitiated).async {
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
