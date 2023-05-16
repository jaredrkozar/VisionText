//
//  ViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit
import CoreData

class AllDocsViewController: UIViewController, ImageSelectedDelegate, NSFetchedResultsControllerDelegate {
    
    
    var reusabletableView: ReusableTableViewController!
    var documents: NSFetchedResultsController<Document>?
    
    override func viewDidLoad() {
        
        self.reusabletableView = ReusableTableViewController(frame: .zero)
        documents = returnFetchController(sortType: SortMethods.AZ, isStarred: false)
        
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
        self.navigationItem.rightBarButtonItems = [sortDocs, addDoc]
    }
    
    private func createSortDocMenu() -> UIMenu {
        var sortActions = [UIAction]()
        
        for sort in SortMethods.allCases {
            sortActions.append(UIAction(title: sort.buttonText, image: nil, identifier: nil, discoverabilityTitle: sort.buttonText, attributes: [], state: .off, handler: { _ in
                
                self.sortDocs(sort: sort.buttonText)
            }))
        }
        
        return UIMenu(title: "Add Document", image: nil, identifier: nil, options: [], children: sortActions)
    }
    
    private func sortDocs(sort: String) {
        switch sort {
            case SortMethods.AZ.buttonText:
            documents = returnFetchController(sortType: SortMethods.AZ, isStarred: false)
            case SortMethods.ZA.buttonText:
            documents = returnFetchController(sortType: SortMethods.ZA, isStarred: false)
            case SortMethods.datedescending.buttonText:
            documents = returnFetchController(sortType: SortMethods.datedescending, isStarred: false)
            case SortMethods.dateascending.buttonText:
            documents = returnFetchController(sortType: SortMethods.dateascending, isStarred: false)
        default:
            return
        }
        
        do {
             try documents?.performFetch()
         } catch {
             print(error)
         }
    }
    
    private var selectedSource: SourceType?
    
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
            
            let nameAlert = Alerts().presentNameAlert(titleDoc: nil, completionHandler: { title in
                
                let alert = Alerts().presentLoadingAlert()
                
                self.present(alert, animated: true)
                
                DispatchQueue.global(qos: .utility).async {
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
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Document>()
            diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(docs ?? [])
        reusabletableView.applySnapshot(documents: docs ?? [])
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("DLDLLD")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        print("DLDLDffdcvfdcvfdxcvfd")
    }
}
