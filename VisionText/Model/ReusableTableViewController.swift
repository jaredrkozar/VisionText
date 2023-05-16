//
//  ReusableTableViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 3/28/23.
//

import UIKit
import CoreData
class ReusableTableViewController: UITableView, UITableViewDelegate {

    var vc: UIViewController?
    var currentDocuments: NSFetchedResultsController<Document>?
    
    var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Document>()
    
    lazy var tabledataSource = configureDataSource()
    
    var tableView: UITableView
    
    init(frame: CGRect) {
        tableView = UITableView(frame: frame, style: .insetGrouped)
        super.init(frame: frame, style: .insetGrouped)
        tableView.rowHeight =  150
        tableView.dataSource = tabledataSource
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: DocumentTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Int, Document> {
     
        let dataSource = UITableViewDiffableDataSource<Int, Document>(tableView: tableView) { (tableView, indexPath, icon) ->
            DocumentTableViewCell? in

            let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.identifier, for: indexPath) as! DocumentTableViewCell
            if let titleDoc = icon.title {
                cell.documentTitle.text = titleDoc
            }
            
            if let documentDate = icon.date {
                cell.documentDate.text = documentDate.formatted()
            }
            
            if let documentThumbnail = icon.thumbnail {
                cell.documentThumbnail.image = UIImage(data: documentThumbnail)
            }
            
            cell.starImage.isHidden = !icon.isStarred
            
            return cell
        }
     
        return dataSource
    }
    
    func applySnapshot(documents: [Document]) {
      
        diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Document>()
        
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(documents)
        
        tabledataSource.applySnapshotUsingReloadData(diffableDataSourceSnapshot)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = self.tabledataSource.itemIdentifier(for: indexPath)

        let recognizedTextVC = RecognizedTextViewController()
        recognizedTextVC.document = document

        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                vc?.show(recognizedTextVC, sender: self)
            case .pad, .mac:
            
                vc?.splitViewController?.setViewController(recognizedTextVC, for: .secondary)
                vc?.showDetailViewController(recognizedTextVC, sender: nil)

            default:
                break
        }
    }
    
 
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let document = self.tabledataSource.itemIdentifier(for: indexPath)
        
            let renameAction = UIContextualAction(style: .normal, title: "Rename") {  (contextualAction, view, boolValue) in
                self.renameItem(document: document!)
            }
        
            renameAction.image = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
            renameAction.backgroundColor = .systemBlue

        let starAction = UIContextualAction(style: .normal, title: document?.isStarred ?? false ? "Un-Star" : "Star") {  (contextualAction, view, boolValue) in
            self.toggleStar(document: document!)
            }
        
            starAction.image = UIImage(systemName: document?.isStarred ?? false ? "star.slash" : "star.fill")
            starAction.backgroundColor = .systemYellow
        
            let swipeActions = UISwipeActionsConfiguration(actions: [renameAction, starAction])
        swipeActions.performsFirstActionWithFullSwipe = false
            return swipeActions
        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let document = self.tabledataSource.itemIdentifier(for: indexPath)!
        
        let item = UIContextualAction(style: .normal, title: "Delete") {  (contextualAction, view, boolValue) in
            self.deleteItem(document: document)
            }
        item.backgroundColor = .systemRed
        item.image = UIImage(systemName: "trash")

        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        swipeActions.performsFirstActionWithFullSwipe = false
            return swipeActions
        }
    
    func toggleStar(document: Document) {
        let newStatus: Bool = !document.isStarred
        document.updateDocumentStarredStatus(isStarred: newStatus)
    }
    
    func deleteItem(document: Document) {
        document.deleteDocument()
    }
    
    func renameItem(document: Document) {
  
        let renameAlert = Alerts().presentNameAlert(alertTitle: "Rename Document", completionHandler: { title in
            
            document.renameDocument(newTitle: title ?? "Untitled Document")
            
        })
        
        vc?.present(renameAlert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
