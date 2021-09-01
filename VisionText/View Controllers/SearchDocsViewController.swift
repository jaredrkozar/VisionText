//
//  SearchDocumentsTableViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/17/21.
//

import UIKit

class SearchDocsViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var searchBar: UISearchBar = UISearchBar()
    var searchedDocuments = [Documents]()
    var documentDetails = [Documents]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        searchBar.delegate = self
        view.addSubview(navBar)
        
        title = "Search Documents"
        
        let nib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DocumentTableViewCell")

        setUpTableView()
        setupSearchBar()
        constraints()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard

        if let savedDocs = defaults.object(forKey: "documentDetails") as? Data {
            if let decodedDocs = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedDocs) as? [Documents] {
                documentDetails = decodedDocs
            }
        }
    }
    
    func setupSearchBar() {
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search Documents"
        searchBar.barTintColor = UIColor.systemBackground
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.frame = CGRect(x: 0, y: 15, width: 400, height: 50)
        view.addSubview(searchBar)
        
    }
    
    func setUpTableView() {
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 167
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 75))
        self.tableView.tableHeaderView = headerView
    }
    
    func constraints() {
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
           ])
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        
        if searchText == "" {
            tableView.reloadData()
        } else {
            for document in documentDetails {
                if document.name.lowercased().contains(searchText.lowercased()) {
                    searchedDocuments.removeAll()
                    searchedDocuments.append(document)
                    tableView.reloadData()
                }
                
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchedDocuments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as? DocumentTableViewCell else {
            fatalError("Unable to dequeue the document cell.")
        }
        
        let document = searchedDocuments[indexPath.row]
        
        cell.documentName.text = document.name

        cell.documentThumbnail.image = document.thumbnail.toImage()

        cell.documentDate.text = document.date
        
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
        
        let document = searchedDocuments[indexPath.row]
        let vc = ScannedImageViewController()
        vc.titleDoc = document.name
        vc.scannedImage = document.thumbnail
        showDetailViewController(vc, sender: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
}

