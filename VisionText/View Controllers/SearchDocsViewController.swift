//
//  SearchDocumentsTableViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/17/21.
//
import UIKit
import CoreData

class SearchDocsViewController: UIViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var reusabletableView: ReusableTableViewController!
    var documents: NSFetchedResultsController<Document>?
    var currentSearchText = ""
    
    lazy var noSearchResultsLabel: UILabel = {
        let noDocLabel = UILabel()
        noDocLabel.textAlignment = .center
        noDocLabel.text = "There are no documents that match your current search results"
        noDocLabel.textColor = .systemGray2
        noDocLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        noDocLabel.numberOfLines = 0
        noDocLabel.translatesAutoresizingMaskIntoConstraints = false
        return noDocLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Documents"
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        title = "Search Documents"
        self.reusabletableView = ReusableTableViewController(frame: .zero)
        
        reusabletableView.vc = self
        
        reusabletableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reusabletableView)
        NSLayoutConstraint.activate([
            reusabletableView.topAnchor.constraint(equalTo: view.topAnchor),
            reusabletableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reusabletableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reusabletableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = searchController.searchBar.text!
        documents = returnFetchController(sortType: SortMethods.AZ, isStarred: false, searchTerm: text)
        
        do {
             try documents?.performFetch()
         } catch {
             print(error)
         }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let docs = controller.fetchedObjects as? [Document]
        
        if docs!.count == 0 && !searchController.searchBar.text!.isEmpty {
            
            view.addSubview(noSearchResultsLabel)
            
            NSLayoutConstraint.activate([
                noSearchResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noSearchResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                noSearchResultsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.70),
                noSearchResultsLabel.heightAnchor.constraint(equalToConstant: 100)
            ])
        } else {
            noSearchResultsLabel.removeFromSuperview()
        }
        
        reusabletableView.applySnapshot(documents: docs ?? [])
    }
}
