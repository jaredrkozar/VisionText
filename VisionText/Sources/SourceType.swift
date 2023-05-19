//
//  SourceType.swift
//  VisionText
//
//  Created by Jared Kozar on 3/24/23.
//

import UIKit

protocol SourceType {
    func presentView()
    var imageDelegate: ImageSelectedDelegate? { get set }
    var viewController: UIViewController? { get set }
}

protocol ImageSelectedDelegate:class {
    func imageSelected(image: [UIImage])
}

protocol FetchedResultsDelegate:class {
    func updateTable()
}

