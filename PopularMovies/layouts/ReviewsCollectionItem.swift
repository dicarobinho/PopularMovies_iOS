//
//  ReviewsCollectionItem.swift
//  PopularMovies
//
//  Created by Macbook on 04/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit

class ReviewsCollectionItem: UICollectionViewCell {
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    static let identifier = "ReviewsCollectionItem"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setAuthor(with authorName: String) {
        authorLabel.text = authorName
    }
    
    public func setContent(with content: String) {
        contentLabel.text = content
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ReviewsCollectionItem", bundle: nil)
    }
}
