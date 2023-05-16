//
//  TabBarController.swift
//  VisionText
//
//  Created by Jared Kozar on 7/18/21.
//

import UIKit

class TabBarController: UITabBarController {

    private lazy var allDocumentsViewController = makeViewController()
    private lazy var starredDocumentsViewController = makeStarredViewController()
    private lazy var searchDocumentsViewController = makeSearchDocumentsTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [allDocumentsViewController,
                           starredDocumentsViewController, searchDocumentsViewController]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = 0
    }

}

private extension TabBarController {

    private func makeViewController() -> UINavigationController {
        let vc = AllDocsViewController(filterByStarred: false)
       
        vc?.tabBarItem = UITabBarItem(title: "All Documents",
                                     image: UIImage(systemName: "square.grid.2x2.fill"),
                                     tag: 0)
        return UINavigationController(rootViewController: vc!)
    }

    private func makeStarredViewController() -> UINavigationController {
        let vc = AllDocsViewController(filterByStarred: true)
        vc?.tabBarItem = UITabBarItem(title: "Starred Documents",
                                     image: UIImage(systemName: "star.fill"),
                                     tag: 1)

        return UINavigationController(rootViewController: vc!)
    }

    private func makeSearchDocumentsTableViewController() -> UINavigationController {
        let vc = SearchDocsViewController()
        vc.tabBarItem = UITabBarItem(title: "Search Documents",
                                     image: UIImage(systemName: "magnifyingglass"),
                                     tag: 2)
        return UINavigationController(rootViewController: vc)
    }
    
}
