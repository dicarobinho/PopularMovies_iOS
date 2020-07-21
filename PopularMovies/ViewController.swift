//
//  ViewController.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import UIKit
import Reachability
import RealmSwift

class ViewController: UIViewController {
    
    //comment 1
    
    @IBOutlet weak var collectionMoviesView: UICollectionView!
    
    @IBOutlet weak var indicateMoviesPageLabel: UILabel!
    @IBOutlet weak var indicateMoviesTypeLabel: UILabel!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    
    
    @IBOutlet weak var nextPageButton: UIBarButtonItem!
    @IBOutlet weak var prevPageButton: UIBarButtonItem!
    @IBOutlet weak var favoriteMoviesButton: UIBarButtonItem!
    
    let numberOfGridViewColumns:CGFloat = 2
    
    var pageMovies:PageMovies!
    var listWithFavoriteMovies = [Movie]()
    
    var clickedItemIndex:Int!
    var currentMoviesPage:Int = 1
    
    // 0 pentru popular, 1 pentru vote, 2 pentru favorite
    var typeMovies:Int = 0
    var noInternetConnection:Bool = false
    
    var reachability = try! Reachability()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwipesMethods()
        makeUiViewsRounded()
        //animFadeInDisableLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectionCheck()
        //setUpFavoriteButton()
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
    
    @IBAction func favoriteMovies(_ sender: Any) {
        if typeMovies == 1 || typeMovies == 0 {
            
            typeMovies = 2
            disableEnableTabButtons(false)
            
            let realm = try! Realm()
            let moviesFromDb = RealmDatabase.getAllMoviesFromDb(realm)
            
            if moviesFromDb.count != 0 {
                //ajutor pt identificarea ultimului film din array (solutie temporara)
                var counter:Int = 0
                for movie in moviesFromDb {
                    counter += 1
                    if counter < moviesFromDb.count {
                        getSpecificMovieFromServer(String(movie.getId()), false)
                    } else {
                        getSpecificMovieFromServer(String(movie.getId()), true)
                    }
                }
            } else {
                 self.collectionMoviesView.reloadData()
                 self.setUI()
            }
            
            indicateMoviesTypeLabel.text = Constants.FAVORITE
        }
    }
    
    @IBAction func topRatedMovies(_ sender: Any) {
        if typeMovies == 0 || typeMovies == 2 {
            typeMovies = 1
            disableEnableTabButtons(true)
            //setUpFavoriteButton()
            
            listWithFavoriteMovies.removeAll()
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_VOTE)
            indicateMoviesTypeLabel.text = Constants.TOP_RATED
        }
    }
    
    @IBAction func popularMovies(_ sender: Any) {
        if typeMovies == 1 || typeMovies == 2 {
            typeMovies = 0
            disableEnableTabButtons(true)
            //setUpFavoriteButton()
            
            listWithFavoriteMovies.removeAll()
            getMoviesFromServer(currentMoviesPage, Constants.SORT_BY_POPULARITY)
            indicateMoviesTypeLabel.text = Constants.POPULAR
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
    
    func getSpecificMovieFromServer(_ movieId:String, _ lastMovie:Bool) {
        MovieServiceAPI.shared.fetchSpecificMovie(movieId) { (result: Result<Movie, MovieServiceAPI.APIServiceError>) in
            switch result {
            case .success(let movieResponse):
                
                self.listWithFavoriteMovies.append(movieResponse)
                
                if lastMovie {
                // rulam partea aceasta de cod in main thread
                DispatchQueue.main.async {
                    self.collectionMoviesView.reloadData()
                    self.setUI()
                    }
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
    
    // returnam adresa la care se gaseste posterul
    // daca adresa poster-ului e nil, atunci returnam o adresa default
    func getPosterUrl (_ itemIndex: Int) -> URL {
        if typeMovies != 2 {
            if pageMovies.results[itemIndex].posterPath != nil {
                return URL(string: Constants.IMAGE_BASE_URL + pageMovies.results[itemIndex].posterPath!)!
            } else {
                return URL(string: Constants.NO_PICTURE_AVAILABLE_ICON)!
            }
        } else {
            if listWithFavoriteMovies[itemIndex].posterPath != nil {
                return URL(string: Constants.IMAGE_BASE_URL + listWithFavoriteMovies[itemIndex].posterPath!)!
            } else {
                return URL(string: Constants.NO_PICTURE_AVAILABLE_ICON)!
            }
        }
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
    
//    func disableEnableFavoriteMoviesButton(_ enable:Bool) {
//        if enable {
//            favoriteMoviesButton.isEnabled = true
//        } else {
//            favoriteMoviesButton.isEnabled = false
//        }
//    }
    
   func disableEnableTabButtons(_ enable:Bool){
        if enable {
            prevPageButton.isEnabled = true
            nextPageButton.isEnabled = true
            indicateMoviesPageLabel.isHidden = false
        } else {
            prevPageButton.isEnabled = false
            nextPageButton.isEnabled = false
            indicateMoviesPageLabel.isHidden = true
        }
    }
    
//    func setUpFavoriteButton() {
//        if RealmDatabase.verifyIfDbIsClear(realm) {
//            disableEnableFavoriteMoviesButton(false)
//        } else {
//            disableEnableFavoriteMoviesButton(true)
//        }
//    }
    
    // trimitem informatia necesara catre view controller-ul indicat
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is DetailsMovieViewController {
            
            let controller = segue.destination as! DetailsMovieViewController
            if typeMovies != 2 {
                controller.selectedMovie = pageMovies.results[clickedItemIndex]
            } else {
                controller.selectedMovie = listWithFavoriteMovies[clickedItemIndex]
            }
        }
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
        if noInternetConnection == false && typeMovies != 2 {
            return pageMovies.results.count
        } else if noInternetConnection == false {
            return listWithFavoriteMovies.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if typeMovies != 2 {
            if pageMovies.results[indexPath.item].voteAverage != -1 {
                if pageMovies.results[indexPath.item].voteAverage == 10.0 {
                    cell.setRating(with: "10")
                } else {
                    cell.setRating(with: String(pageMovies.results[indexPath.item].voteAverage))
                }
            } else {
                cell.setRating(with: "0.0")
            }
            
            cell.setImage(with: getPosterUrl(indexPath.item))
            cell.disableFavoriteMovieStar()
        } else {
            print(indexPath.item)
            if listWithFavoriteMovies[indexPath.item].voteAverage != -1 {
                if listWithFavoriteMovies[indexPath.item].voteAverage == 10.0 {
                    cell.setRating(with: "10")
                } else {
                    cell.setRating(with: String(listWithFavoriteMovies[indexPath.item].voteAverage))
                }
            } else {
                cell.setRating(with: "0.0")
            }
            
            cell.setImage(with: getPosterUrl(indexPath.item))
            cell.disableFavoriteMovieStar()
        }
        
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
