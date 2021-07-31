//
//  StarredViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/17/21.
//

import UIKit

class StarredDocsViewController: UITableViewController {
    var documentDetails = [Documents]()
    
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
        
        let defaults = UserDefaults.standard

        if let savedDocs = defaults.object(forKey: "documentDetails") as? Data {
            if let decodedDocs = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedDocs) as? [Documents] {
                documentDetails = decodedDocs
            }
        }
        
        print(documentDetails.count)
        tableView.reloadData()
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 167
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 500),
           ])
    }
    
    func returnStarredDocs() -> [Documents] {
        documentDetails = documentDetails.filter{$0.isStarred == true }
        return documentDetails
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

        cell.documentThumbnail.image = document.thumbnail

        cell.documentDate.text = document.date
        print(document.thumbnail)
        cell.layoutIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let document = documentDetails[indexPath.row]
        let vc = ScannedImageViewController()
        
        vc.titleDoc = document.name
        vc.scannedImage = document.thumbnail
        
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
        let document = documentDetails[indexPath.row]
        //saves the row the user bought the context menu appear on in row
        let row = indexPath.row
        UserDefaults.standard.set(row, forKey: "row")
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let unstarAction = UIAction(title: "Unstar", image: UIImage(systemName: "star.fill")) { [self] _ in
                
                unstarDocument(indexPath: indexPath)
                
            }
            
                
            let renameAction = UIAction(
                //deletes the current cell
              title: "Rename",
              image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { [self] _ in
                
                renameDocument(tableView, indexPath: indexPath)
            }
            
            return UIMenu(title: "", children: [renameAction, unstarAction])
        }
    }
    
    func unstarDocument(indexPath: IndexPath) {
        let starred = documentDetails[indexPath.row]
        
        starred.isStarred = false
        documentDetails.remove(at: indexPath.row)
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.saveStarred()
        }
        tableView.reloadData()
    }
    
    func renameDocument(_ tableView: UITableView, indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        
        let ac = UIAlertController(title: "Rename Document", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let textField = ac?.textFields![0]
            self!.documentDetails[indexPath.row].name = (textField?.text)!
            self!.saveStarred()
            self!.tableView.reloadData()
            
        })
        present(ac, animated: true)
    }
    
    func saveStarred() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: documentDetails, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "documentDetails")
        }
    }
}
