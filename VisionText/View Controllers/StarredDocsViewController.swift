//
//  StarredViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/17/21.
//

import UIKit

class StarredDocsViewController: UITableViewController {
    var starredArray = [Documents]()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        starredArray = starredArray.loadStarred()
        tableView.reloadData()
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 167
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 500),
           ])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starredArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let document = starredArray[indexPath.row]

        cell.documentName.text = document.name

        cell.documentThumbnail.image = document.thumbnail.toImage()

        cell.documentDate.text = document.date
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the image cell.")
        }
        
        let document = starredArray[indexPath.row]
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
        let document = starredArray[indexPath.row]
        //saves the row the user bought the context menu appear on in row
        let row = indexPath.row
        UserDefaults.standard.set(row, forKey: "row")
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let unstarAction = UIAction(title: "Unstar", image: UIImage(systemName: "star.fill")) { [self] _ in
                
                unstarDocument(indexPath: indexPath)
                
            }
            return UIMenu(title: "", children: [unstarAction])
        }
    }
    
    func unstarDocument(indexPath: IndexPath) {
        let starred = starredArray[indexPath.row]
        
        starred.isStarred = false
        starredArray.remove(at: indexPath.row)
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.starredArray.saveStarred()
        }
        tableView.reloadData()
    }
}
