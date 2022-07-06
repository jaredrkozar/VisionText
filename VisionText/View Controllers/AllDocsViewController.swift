//
//  ViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit

class AllDocsViewController: UITableViewController & UINavigationControllerDelegate, UITableViewDropDelegate {
    
    var sortButton = UIButton()
    var dataSource = ReusableDocumentsTableView()
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {        setUpTableView()
        fetchDocuments(sortType: "date", isAscending: false, isStarred: filterByStarred)
        dataSource.documentDetails = documents
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        if filterByStarred == false {
            title = "All Documents"
        } else {
            title = "Starred Documents"
        }
        
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
        } else if sortMethod == "Date (Ascending)" {
            sortDocsbyDateAscending()
        } else if sortMethod == "Date (Descending)" {
            sortDocsbyDateDescending()
        }
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
        fetchDocuments(sortType: "title", isAscending: true, isStarred: filterByStarred)
        dataSource.documentDetails = documents
        self.tableView.reloadData()
    }
    
    @objc func sortDocsByZA() {
        fetchDocuments(sortType: "title", isAscending: false, isStarred: filterByStarred)
        dataSource.documentDetails = documents
        self.tableView.reloadData()
    }
    
    @objc func sortDocsbyDateAscending() {
        fetchDocuments(sortType: "date", isAscending: true, isStarred: filterByStarred)
        dataSource.documentDetails = documents
        self.tableView.reloadData()
    }
    
    @objc func sortDocsbyDateDescending() {
        fetchDocuments(sortType: "date", isAscending: false, isStarred: filterByStarred)
        dataSource.documentDetails = documents
        self.tableView.reloadData()
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = 167
        tableView.dropDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    func presentAlert(imageToPresent: UIImage) {
        let ac = UIAlertController(title: "Name Document", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
                        
            let thumbnailasString = imageToPresent.converttoString()
            
            var text: String?
            
            imageToPresent.recognizeText(completion: { (doctext, error) in
                
                if error != nil {
                    let alertController = UIAlertController(title: "An error occured while saving the document", message: "\(error). Please try saving the document again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self?.present(alertController, animated: true)
        
                } else {
                    text = doctext
                    saveDocument(thumbnail: thumbnailasString, title: textField?.text ?? "Untitled", date: self!.getCurrentShortDate(), isStarred: false, documentID: UUID().uuidString, text: text
                    )
                    
              self!.tableView.reloadData()

                }
          })

        })
        present(ac, animated: true)
    }

    func getCurrentShortDate() -> Date {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy, h:mm a"

        return todaysDate
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "row")
        let document = self.dataSource.documentDetails[indexPath.row]
        let vc = ScannedImageViewController()
        let navController = UINavigationController(rootViewController: vc)
        
        let documentCell = tableView.cellForRow(at: indexPath) as! DocumentTableViewCell
        documentCell.documentName.textColor = UIColor.tertiaryLabel
        documentCell.documentDate.textColor = UIColor.tertiaryLabel
        
        vc.document = document

        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                navigationController?.pushViewController(navController, animated: true)
        case .pad, .mac:
            splitViewController?.setViewController(navController, for: .secondary)
            
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
        let document = self.dataSource.documentDetails[indexPath.row]
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
                
                    deleteSelectedDocument(tableView, indexPath: indexPath)

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
    
    func deleteSelectedDocument(_ tableView: UITableView, indexPath: IndexPath) {
        
        deleteDocument(document: dataSource.documentDetails[indexPath.row])
        
        self.dataSource.documentDetails.remove(at: indexPath.row)

        tableView.reloadData()
    }
    
    func toggleStar(indexPath: IndexPath) {
        let document = dataSource.documentDetails[indexPath.row]
        document.isStarred.toggle()
        tableView.reloadData()

    }
    
    func renameDocument(_ tableView: UITableView, indexPath: IndexPath) {

        let ac = UIAlertController(title: "Rename Document", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
            self!.dataSource.documentDetails[indexPath.row].title = (textField?.text)!
            self!.tableView.reloadData()
            
        })
        present(ac, animated: true)
    }
}
