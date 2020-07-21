//
//  MyCollectionViewCell.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicateRatingLabel: UILabel!
    @IBOutlet weak var indicateMovieFavorite: UIImageView!
    
    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        makeRatingLabelRounded()
    }

    public func setImage(with imageURL: URL) {
        imageView.load(url: imageURL)
    }
    
    public func setRating(with text: String) {
        indicateRatingLabel.text = text
    }
    
    public func disableFavoriteMovieStar() {
        indicateMovieFavorite.isHidden = true
    }
    
    public func enableFavoriteMovieStar() {
        indicateMovieFavorite.isHidden = false
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    func makeRatingLabelRounded () {
        indicateRatingLabel.layer.cornerRadius = 15
        indicateRatingLabel.clipsToBounds = true
    }
}

// help to load image into ImageView from URL
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
