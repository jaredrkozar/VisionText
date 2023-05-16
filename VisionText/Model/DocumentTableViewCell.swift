//
//  DocumentTableViewCell.swift
//  VisionText
//
//  Created by Jared Kozar on 7/31/21.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    
    static let identifier = "DocumentTableViewCell"
    var documentTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: .current)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    var documentDate: UILabel = {
        let documentDate = UILabel()
        documentDate.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current)
        documentDate.textColor = .systemGray
        documentDate.translatesAutoresizingMaskIntoConstraints = false
        return documentDate
    }()
    
    var documentThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var starImage: UIImageView = {
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let star = UIImageView()
        star.image = UIImage(systemName: "star.fill", withConfiguration: config)
        star.contentMode = .scaleAspectFit
        star.translatesAutoresizingMaskIntoConstraints = false
        return star
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func layoutSubviews() {
        
        self.addSubview(documentTitle)
        self.addSubview(documentDate)
        self.addSubview(documentThumbnail)
        self.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            documentThumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            documentThumbnail.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            documentThumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            documentThumbnail.widthAnchor.constraint(equalToConstant: 150),
            
            documentTitle.leadingAnchor.constraint(equalTo: documentThumbnail.trailingAnchor, constant: 5),
            documentTitle.topAnchor.constraint(equalTo: documentThumbnail.topAnchor),
            documentTitle.widthAnchor.constraint(equalToConstant: 150),
            
            documentDate.leadingAnchor.constraint(equalTo: documentThumbnail.trailingAnchor, constant: 5),
            documentDate.topAnchor.constraint(equalTo: documentTitle.bottomAnchor),
            
            starImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            starImage.topAnchor.constraint(equalTo: documentTitle.topAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 30),
            starImage.heightAnchor.constraint(equalTo: documentTitle.heightAnchor),
        ])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
