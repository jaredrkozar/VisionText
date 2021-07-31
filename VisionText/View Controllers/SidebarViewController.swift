import UIKit

class SidebarViewController: UIViewController {
    var folders = [String]()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var collectionView: UICollectionView! = nil
    private var supplementaryViewControllers = [UINavigationController(rootViewController: AllDocsViewController()),
                                                UINavigationController(rootViewController: StarredDocsViewController()), UINavigationController(rootViewController: SearchDocsViewController())
    
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "VisionText"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureHierarchy()
        
        NotificationCenter.default.addObserver(self, selector: #selector(configureDataSource(_:)), name: NSNotification.Name( "configureDataSource"), object: nil)
        NotificationCenter.default.post(name: Notification.Name( "configureDataSource"), object: nil)
        
        addNavigationButtons()
        setInitialSecondaryView()

    }
    
    private func setInitialSecondaryView() {
        collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                  animated: false,
                                  scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
        splitViewController?.setViewController(supplementaryViewControllers[0], for: .supplementary)
    }

    private func addNavigationButtons() {
        let editsidebar = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
        
//        let addcollection = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(addFolderButtonTapped))
//
        navigationItem.rightBarButtonItems = [editsidebar]
    }
    
//    @objc func addFolderButtonTapped(_ sender: UIBarButtonItem) {
//        let ac = UIAlertController(title: "Add Folder", message: nil, preferredStyle: .alert)
//        ac.addTextField()
//
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
//            var textField = ac?.textFields![0]
//            UserDefaults.standard.set(textField?.text, forKey: "text")
//            print(collectionItems.count)
//            NotificationCenter.default.post(name: Notification.Name( "configureDataSource"), object: nil)
//        })
//        present(ac, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
}

// MARK: - Layout

extension SidebarViewController {

    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            
            config.trailingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
                    
                guard let item = dataSource.itemIdentifier(for: indexPath) else {
                        return nil
                    }
                    
                let deletecollection = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
 
                    self.delete(at: indexPath)
                    completion(true)
                }
                deletecollection.backgroundColor = .systemRed
                
                // Use all the actions to create a swipe action configuration
                // Return it to the swipe action configuration provider
                
                let sections: [Section] = [.tabs, .collections]

                switch indexPath.section {
                    case 0:
                        return nil
                    default:
                        switch indexPath.row {
                            case 0:
                                return nil
                            default:
                                return UISwipeActionsConfiguration(actions: [deletecollection])
                        }
                }
            }
            

            config.headerMode = section == 0 ? .none : .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    func delete(at ip: IndexPath) {
        var snap = self.dataSource.snapshot()
        if let ident = self.dataSource.itemIdentifier(for: ip) {
            snap.deleteItems([ident])
        }
        self.dataSource.apply(snap)
    }
}

// MARK: - Data

extension SidebarViewController {
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func configureDataSource(_ notification: Notification) {
        // Configuring cells

        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
            cell.accessories = []
        }

        // Creating the datasource

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            if indexPath.item == 0 && indexPath.section != 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
                
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
            
            
        }

        // Creating and applying snapshots

        let sections: [Section] = [.tabs, .collections]
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)

        for section in sections {
            switch section {
            case .tabs:
                var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                sectionSnapshot.append(tabsItems)
                dataSource.apply(sectionSnapshot, to: section)

            case .collections:
                let headerItem = Item(title: section.rawValue, image: nil)
                var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                sectionSnapshot.append([headerItem])
                
                var text = UserDefaults.standard.string(forKey: "text")
                
                if text != nil {
                    collectionItems.append(Item(title: "\(text!)", image: UIImage(systemName: "folder")))
                }
                sectionSnapshot.append(collectionItems, to: headerItem)
                
                sectionSnapshot.expand([headerItem])
                dataSource.apply(sectionSnapshot, to: section)
                
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SidebarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        splitViewController?.setViewController(supplementaryViewControllers[indexPath.row], for: .supplementary)
        
        view.window?.windowScene?.title = tabsItems[indexPath.row].title
    }

}

// MARK: - Structs and sample data

struct Item: Hashable {
    let title: String?
    let image: UIImage?
    private let identifier = UUID()
}

var tabsItems = [Item(title: "All Documents", image: UIImage(systemName: "square.grid.2x2")),
                 Item(title: "Starred Documents", image: UIImage(systemName: "star")),
                 Item(title: "Search Documents", image: UIImage(systemName: "magnifyingglass"))
                ]


var collectionItems = [
    Item(title: "Sample Folder", image: UIImage(systemName: "folder"))]

enum Section: String {
    case tabs
    case collections = "Collections"
}
