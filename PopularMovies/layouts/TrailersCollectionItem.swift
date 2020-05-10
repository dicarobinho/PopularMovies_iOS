//
//  TrailersCollectionItem.swift
//  PopularMovies
//
//  Created by Macbook on 04/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit

class TrailersCollectionItem: UICollectionViewCell {

    @IBOutlet weak var trailerNameLabel: UILabel!
    @IBOutlet weak var trailerTypeLabel: UILabel!
    
    static let identifier = "TrailersCollectionItem"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setTrailerName(with trailerName: String) {
        trailerNameLabel.text = trailerName
    }
    
    public func setTrailerType(with trailerType: String) {
        trailerTypeLabel.text = trailerType
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "TrailersCollectionItem", bundle: nil)
    }
}
