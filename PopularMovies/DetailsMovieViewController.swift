//
//  DetailsMovieViewController.swift
//  PopularMovies
//
//  Created by Macbook on 04/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit

class DetailsMovieViewController: UIViewController {
    
    
    @IBOutlet weak var collectionTrailersReviewsView: UICollectionView!
    
    @IBOutlet weak var noTrailersReviewsLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var releaseYear:String!
    var voteAverage:String!
    var descriptionn:String!
    var poster:URL!
    var movieId:Int!
    
    var pageVideos:PageVideos!
    var pageReviews:PageReviews!
    var clickedItemIndex:Int!
    
    var typeCollectionItems:Int! = 0
    
    var layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        releaseYearLabel.text = releaseYear
        voteAverageLabel.text = voteAverage
        descriptionLabel.text = descriptionn
        posterImageView.load(url: poster)
        
        getVideosFromServer()
    }
    
    @IBAction func trailersMovie(_ sender: Any) {
        if typeCollectionItems == 1 {
            getVideosFromServer()
            typeCollectionItems = 0
        }
    }
    
    @IBAction func reviewsMovie(_ sender: Any) {
        if typeCollectionItems == 0 {
            getReviewsFromServer()
            typeCollectionItems = 1
        }
    }
    
    func scrollToTop() {
        //scroll to top
        self.collectionTrailersReviewsView.scrollToItem(at: NSIndexPath(item: 0, section:0) as IndexPath,at:.top,animated: true)
    }
    
    func getVideosFromServer() {
        MovieServiceAPI.shared.fetchVideos(String(movieId)) { (result: Result<PageVideos, MovieServiceAPI.APIServiceError>) in
            switch result {
            case .success(let movieResponse):
                
                self.pageVideos = movieResponse
                self.typeCollectionItems = 0
                
                // rulam partea aceasta de cod in main thread
                DispatchQueue.main.async {
                    self.collectionTrailersReviewsView.reloadData()
                    self.setUIVideos()
                    self.scrollToTop()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getReviewsFromServer() {
        MovieServiceAPI.shared.fetchReviews(String(movieId)) { (result: Result<PageReviews, MovieServiceAPI.APIServiceError>) in
            switch result {
            case .success(let movieResponse):
                
                self.pageReviews = movieResponse
                self.typeCollectionItems = 1
                
                // rulam partea aceasta de cod in main thread
                DispatchQueue.main.async {
                    self.collectionTrailersReviewsView.reloadData()
                    self.setUIReviews()
                    self.scrollToTop()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setUIReviews() {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        
        layout.itemSize = CGSize(width: screenWidth, height: 110)
        
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        collectionTrailersReviewsView.collectionViewLayout = layout
        collectionTrailersReviewsView.register(ReviewsCollectionItem.nib(), forCellWithReuseIdentifier: ReviewsCollectionItem.identifier)
        collectionTrailersReviewsView.delegate = self
        collectionTrailersReviewsView.dataSource = self
    }
    
    func setUIVideos() {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        
        layout.itemSize = CGSize(width: screenWidth, height: 60)
        
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 2;
        
        collectionTrailersReviewsView.collectionViewLayout = layout
        collectionTrailersReviewsView.register(TrailersCollectionItem.nib(), forCellWithReuseIdentifier: TrailersCollectionItem.identifier)
        collectionTrailersReviewsView.delegate = self
        collectionTrailersReviewsView.dataSource = self
    }
    
    // obtinel link-ul catre youtube
    func getYoutubeUrl(_ key:String) -> String {
        return Constants.BASE_YOUTUBE_URL + key
    }
    
    // setam label-ul care indica daca cumva nu exista trailers sau reviews disponibile
    func setNoTrailersReviewsAvailable (_ count:Int) {
        if count == 0 {
            noTrailersReviewsLabel.isHidden = false
            if typeCollectionItems == 0 {
                noTrailersReviewsLabel.text = Constants.NO_TRAILERS
            } else {
                noTrailersReviewsLabel.text = Constants.NO_REVIEWS
            }
        } else {
            noTrailersReviewsLabel.isHidden = true
        }
    }
}

extension DetailsMovieViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if typeCollectionItems == 0 {
            // open link to youtube -> trailer
            guard let url = URL(string: getYoutubeUrl(pageVideos.results[indexPath.item].key!)) else { return }
            UIApplication.shared.open(url)
        } else {
            // open link to review
            guard let url = URL(string: pageReviews.results[indexPath.item].url!) else { return }
            UIApplication.shared.open(url)
        }
    }
}

extension DetailsMovieViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if typeCollectionItems == 0 {
            setNoTrailersReviewsAvailable(pageVideos.results.count)
            return pageVideos.results.count
        } else {
            setNoTrailersReviewsAvailable(pageReviews.results.count)
            return pageReviews.results.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if typeCollectionItems == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrailersCollectionItem.identifier, for: indexPath) as! TrailersCollectionItem
            
            cell.setTrailerName(with: pageVideos.results[indexPath.item].name!)
            cell.setTrailerType(with: pageVideos.results[indexPath.item].site! + ", " + pageVideos.results[indexPath.item].type!)
            
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewsCollectionItem.identifier, for: indexPath) as! ReviewsCollectionItem
            
            cell.setAuthor(with: pageReviews.results[indexPath.item].author!)
            cell.setContent(with: pageReviews.results[indexPath.item].content!)
            
            return cell
        }
    }
}
