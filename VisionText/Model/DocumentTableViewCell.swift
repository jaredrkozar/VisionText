//
//  DocumentTableViewCell.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {

    @IBOutlet var documentThumbnail: UIImageView!
    
    @IBOutlet var documentName: UILabel!
    
    @IBOutlet var documentDate: UILabel!
    
    @IBOutlet var documentStatusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
