//
//  ViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit
import CoreData

class AllDocsViewController: UIViewController, ImageSelectedDelegate, NSFetchedResultsControllerDelegate {
    
    var filterByStarred: Bool = false
    var reusabletableView: ReusableTableViewController!
    var documents: NSFetchedResultsController<Document>?
    private var selectedSource: SourceType?
    
    init?(filterByStarred: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.filterByStarred = filterByStarred
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
    override func viewDidLoad() {
        title = filterByStarred ? "Starred Documents" : "All Documents"
        self.reusabletableView = ReusableTableViewController(frame: .zero)
        documents = returnFetchController(sortType: SortMethods.AZ, isStarred: filterByStarred)
        reusabletableView.vc = self
        do {
             try documents?.performFetch()
         } catch {
             print(error)
         }
        
        reusabletableView.isUserInteractionEnabled = true
        reusabletableView.addInteraction(UIDropInteraction(delegate: self))
        
        reusabletableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reusabletableView)
        NSLayoutConstraint.activate([
            reusabletableView.topAnchor.constraint(equalTo: view.topAnchor),
            reusabletableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reusabletableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reusabletableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let addDoc = UIBarButtonItem(title: "Add Document", image: UIImage(systemName: "plus"), primaryAction: nil, menu: createAddDocMenu())
        let sortDocs = UIBarButtonItem(title: "Sort Documents", image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), primaryAction: nil, menu: createSortDocMenu())
        self.navigationItem.rightBarButtonItems = [addDoc, sortDocs]
    }
    
    @objc func selectedMenuItem(_ sender: AnyObject) {
        if let command = sender as? UICommand {
            if let identifier = command.propertyList as? [String: String] {
                if identifier.keys.first == "sortType" {
                    self.sortDocs(sort: identifier["sortType"]!)
                } else if identifier.keys.first == "addDoc" {
                    self.addDoc(type: identifier["addDoc"]!)
                } else {
                    print("Error with UICommand")
                }
            }
        }
        
    }
    
    public func createSortDocMenu() -> UIMenu {
        var sortActions = [UIAction]()
        
        for sort in SortMethods.allCases {
            sortActions.append(UIAction(title: sort.buttonText, image: nil, identifier: nil, discoverabilityTitle: sort.buttonText, attributes: [], state: .off, handler: { _ in
                
                self.sortDocs(sort: sort.buttonText)
            }))
        }
        
        return UIMenu(title: "Sort Documents", image: nil, identifier: nil, options: .singleSelection, children: sortActions)
    }
    
    @objc func sortDocs(sort: String) {
        documents = returnFetchController(sortType: SortMethods.getSortMethod(name: sort)!, isStarred: filterByStarred)
        
        do {
             try documents?.performFetch()
         } catch {
             print(error)
         }
    }
    
    private func addDoc(type: String) {
        self.selectedSource = Sources.getSource(name: type)?.returnPresentView()

        self.selectedSource?.imageDelegate = self
        self.selectedSource?.viewController = self
        self.selectedSource?.presentView()
    }

    private func createAddDocMenu() -> UIMenu {
        var addActions = [UIAction]()
        
        for type in Sources.allCases {
            addActions.append(UIAction(title: type.title, image: type.icon, identifier: nil, discoverabilityTitle: type.title, attributes: [], state: .off, handler: { _ in
                self.addDoc(type: type.title)
            }))
        }
        
        return UIMenu(title: "Add Document", image: nil, identifier: nil, options: [], children: addActions)
    }
    
    func imageSelected(image: UIImage) {
        DispatchQueue.main.async {
            
            let nameAlert = Alerts().presentNameAlert(alertTitle: "Name Document", completionHandler: { title in
                
                let alert = Alerts().presentLoadingAlert()
                
                self.present(alert, animated: true)
                
                DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem).async {
                    image.recognizeText(completion: { recozniedText,error  in
                        
                        alert.dismiss(animated: true)
                        saveDocument(thumbnail: image.downsizeImage(), title: title!, text: recozniedText)
                    })
                }
            })
            
            self.present(nameAlert, animated: true)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let docs = controller.fetchedObjects as? [Document]
        
        reusabletableView.applySnapshot(documents: docs ?? [])
    }
    
}

extension AllDocsViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            // Propose to the system to copy the item from the source app
            return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async {
                    self.imageSelected(image: draggedImage)
                }
                
            })
        }
    }
}
