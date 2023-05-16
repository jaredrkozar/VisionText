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
    
    private func createSortDocMenu() -> UIMenu {
        var sortActions = [UIAction]()
        
        for sort in SortMethods.allCases {
            sortActions.append(UIAction(title: sort.buttonText, image: nil, identifier: nil, discoverabilityTitle: sort.buttonText, attributes: [], state: .off, handler: { _ in
                
                self.sortDocs(sort: sort.buttonText)
            }))
        }
        
        return UIMenu(title: "Sort Documents", image: nil, identifier: nil, options: .singleSelection, children: sortActions)
    }
    
    private func sortDocs(sort: String) {
        switch sort {
            case SortMethods.AZ.buttonText:
            documents = returnFetchController(sortType: SortMethods.AZ, isStarred: filterByStarred)
            case SortMethods.ZA.buttonText:
            documents = returnFetchController(sortType: SortMethods.ZA, isStarred: filterByStarred)
            case SortMethods.datedescending.buttonText:
            documents = returnFetchController(sortType: SortMethods.datedescending, isStarred: filterByStarred)
            case SortMethods.dateascending.buttonText:
            documents = returnFetchController(sortType: SortMethods.dateascending, isStarred: filterByStarred)
        default:
            return
        }
        
        do {
             try documents?.performFetch()
         } catch {
             print(error)
         }
    }
    
    private func createAddDocMenu() -> UIMenu {
        var addActions = [UIAction]()
        
        for type in Sources.allCases {
            addActions.append(UIAction(title: type.title, image: type.icon, identifier: nil, discoverabilityTitle: type.title, attributes: [], state: .off, handler: { _ in
                self.selectedSource = type.returnPresentView()
        
                self.selectedSource?.imageDelegate = self
                self.selectedSource?.viewController = self
                self.selectedSource?.presentView()
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
