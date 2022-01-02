//
//  SearchDocumentsTableViewController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/17/21.
//

import UIKit

class SearchDocsViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var searchBar: UISearchBar = UISearchBar()
    var dataSource = ReusableDocumentsTableView()
    
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
        tableView.dataSource = dataSource
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
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let document = dataSource.documentDetails[indexPath.row]
        let vc = ScannedImageViewController()
        vc.titleDoc = document.title!
        image = document.thumbnail!.toImage()!
        showDetailViewController(vc, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
}

