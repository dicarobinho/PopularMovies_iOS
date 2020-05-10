//
//  ViewController.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit
import Reachability

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionMoviesView: UICollectionView!
    
    @IBOutlet weak var indicateMoviesPageLabel: UILabel!
    @IBOutlet weak var indicateMoviesTypeLabel: UILabel!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    
    let numberOfGridViewColumns:CGFloat = 2
    
    var pageMovies:PageMovies!
    var clickedItemIndex:Int!
    var currentMoviesPage:Int = 1
    
    // 0 pentru popular, 1 pentru vote
    var typeMovies:Int = 0
    var noInternetConnection:Bool = false
    
    var reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwipesMethods()
        makeUiViewsRounded()
        //animFadeInDisableLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectionCheck()
    }
    
    //functie unde se verifica conexiunea la internet
    //si se afiseaza informatiile necesare
    func connectionCheck()
    {
        reachability.whenReachable = { reachability in
            
            // this is called on a background thread, but UI updates must
            // be on the main thread:
            DispatchQueue.main.async {
                self.noInternetConnection = false
                self.noInternetConnectionLabel.isHidden = true
                if self.typeMovies == 0 {
                    self.getMoviesFromServer(self.currentMoviesPage, Constants.SORT_BY_POPULARITY)
                } else {
                   self.getMoviesFromServer(self.currentMoviesPage, Constants.SORT_BY_VOTE)
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            
            // this is called on a background thread, but UI updates must
            // be on the main thread:
            DispatchQueue.main.async {
                self.noInternetConnection = true
                self.noInternetConnectionLabel.isHidden = false
                self.collectionMoviesView.reloadData()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @IBAction func topRatedMovies(_ sender: Any) {
        if typeMovies == 0 {
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_VOTE)
            indicateMoviesTypeLabel.text = Constants.TOP_RATED
            typeMovies = 1
        }
    }
    
    @IBAction func popularMovies(_ sender: Any) {
        if typeMovies == 1 {
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_POPULARITY)
            indicateMoviesTypeLabel.text = Constants.POPULAR
            typeMovies = 0
        }
    }
    
    @IBAction func getPrevMoviesPage(_ sender: Any) {
        if (currentMoviesPage > 1) {
            currentMoviesPage = currentMoviesPage - 1
            setCollectionViewMovies()
        }
    }
    
    @IBAction func getNextMoviesPage(_ sender: Any) {
        if (currentMoviesPage < 500) {
            currentMoviesPage = currentMoviesPage + 1
            setCollectionViewMovies()
        }
    }
    
    @objc func handleSwipes(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left && currentMoviesPage < 500) {
            currentMoviesPage = currentMoviesPage + 1
            setCollectionViewMovies()
        }
        
        if (sender.direction == .right && currentMoviesPage > 1) {
            currentMoviesPage = currentMoviesPage - 1
            setCollectionViewMovies()
        }
    }
    
    func setCollectionViewMovies() {
        if typeMovies == 0 {
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_POPULARITY)
        } else {
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_VOTE)
        }
        indicateMoviesPageLabel.text = "Page " + String(currentMoviesPage)
    }
    
    func getMoviesFromServer(_ page:Int, _ sortType:String) {
        MovieServiceAPI.shared.fetchMovies(page, sortType) { (result: Result<PageMovies, MovieServiceAPI.APIServiceError>) in
            switch result {
            case .success(let movieResponse):
                
                self.pageMovies = movieResponse
                
                // rulam partea aceasta de cod in main thread
                DispatchQueue.main.async {
                    self.collectionMoviesView.reloadData()
                    self.setUI()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setSwipesMethods() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    func setUI() {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth/numberOfGridViewColumns, height: 278)
        
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        collectionMoviesView.collectionViewLayout = layout
        collectionMoviesView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionMoviesView.delegate = self
        collectionMoviesView.dataSource = self
    }
    
    // trimitem informatia necesara catre view controller-ul indicat
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is DetailsMovieViewController {
            
            let controller = segue.destination as! DetailsMovieViewController
            
            controller.releaseYear = getTheYearFromDate(pageMovies.results[clickedItemIndex].releaseDate)
            controller.voteAverage = formatVoteAverage(String(pageMovies.results[clickedItemIndex].voteAverage))
            controller.descriptionn = pageMovies.results[clickedItemIndex].overview
            controller.poster = getPosterUrl(clickedItemIndex)
            controller.movieId = pageMovies.results[clickedItemIndex].id
        }
    }
    
    // returnam adresa la care se gaseste posterul
    // daca adresa poster-ului e nil, atunci returnam o adresa default
    func getPosterUrl (_ itemIndex: Int) -> URL {
        if pageMovies.results[itemIndex].posterPath != nil {
            return URL(string: Constants.IMAGE_BASE_URL + pageMovies.results[itemIndex].posterPath!)!
        } else {
            return URL(string: Constants.NO_PICTURE_AVAILABLE_ICON)!
        }
    }
    
    func getTheYearFromDate (_ date:String) -> String {
        let array = date.components(separatedBy: "-")
        return array[0]
    }
    
    func formatVoteAverage (_ voteAverage:String) -> String {
        return voteAverage + "/10"
    }
    
    func makeUiViewsRounded() {
        makeCornerLabelRounded(indicateMoviesTypeLabel)
        makeCornerLabelRounded(indicateMoviesPageLabel)
    }
    
    func animFadeOutDisableLabel() {
        UIView.animate(withDuration: 0.5, animations: {
            self.indicateMoviesPageLabel.alpha = 0
            self.indicateMoviesTypeLabel.alpha = 0
        })
    }
    
    func animFadeInDisableLabel() {
        UIView.animate(withDuration: 0.5, animations: {
            self.indicateMoviesPageLabel.alpha = 1
            self.indicateMoviesTypeLabel.alpha = 1
        })
        countSecondsAndDisableLabel()
    }
    
    func countSecondsAndDisableLabel() {
        //executa "ceva" dupa 5 secunde
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.animFadeOutDisableLabel()
        }
    }
    
    func makeCornerLabelRounded (_ label:UILabel) {
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        clickedItemIndex = indexPath.item
        
        // lansare scena DetailsMovie
        performSegue(withIdentifier: "detailsMovie", sender: self)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if noInternetConnection == false {
            return pageMovies.results.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if pageMovies.results[indexPath.item].voteAverage != nil {
            if pageMovies.results[indexPath.item].voteAverage == 10.0 {
                cell.setRating(with: "10")
            } else {
                cell.setRating(with: String(pageMovies.results[indexPath.item].voteAverage!))
            }
        } else {
            cell.setRating(with: "0.0")
        }
        
        cell.setImage(with: getPosterUrl(indexPath.item))
        
        return cell
    }
}

//extension ViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        //let screen = UIScreen.main.bounds
//        //let screenWidth = screen.size.width
//
//        return CGSize(width: 200, height: 278)
//    }
//}
