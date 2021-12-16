//
//  StarredViewController.swift
//  Vision
//  Created by Jared Kozar on 7/17/21.
//

import UIKit

class StarredDocsViewController: UITableViewController {
    
    var dataSource = ReusableDocumentsTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Starred Documents"
        
        setUpTableView()
        let nib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DocumentTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
        
        dataSource.documentDetails = docs.filter({$0.isStarred == true})
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 167
        tableView.dataSource = dataSource
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 500),
           ])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let document = dataSource.documentDetails[indexPath.row]
        let vc = ScannedImageViewController()
        
        vc.titleDoc = document.name
        image = document.thumbnail.toImage()!
        
        splitViewController?.setViewController(ScannedImageViewController(), for: .secondary)
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                navigationController?.pushViewController(vc, animated: true)
            case .pad:
                showDetailViewController(vc, sender: true)
            default:
                break
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let unstarAction = UIAction(title: "Unstar", image: UIImage(systemName: "star.fill")) { [self] _ in
                
                unstarDocument(indexPath: indexPath)
            }
            return UIMenu(title: "", children: [unstarAction])
        }
    }
    
    func unstarDocument(indexPath: IndexPath) {
        let starred = dataSource.documentDetails[indexPath.row]
        
        starred.isStarred.toggle()
        tableView.reloadData()
    }
}
