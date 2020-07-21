//
//  Movie.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object, Codable {
    
    @objc dynamic var id = -1
    @objc dynamic var title:String!
    @objc dynamic var posterPath:String!
    @objc dynamic var voteAverage:Float = -1
    @objc dynamic var overview:String!
    @objc dynamic var releaseDate:String!
    @objc dynamic var popularity:Float = -1
    
     init(_ id: Int, _ title: String, _ posterPath: String, _ voteAverage: Float, _ overview: String, _ releaseDate: String, _ popularity: Float) {
        self.id = id;
        self.title = title;
        self.popularity = popularity
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.overview = overview
        self.releaseDate = releaseDate
        
        super.init()
    }
    
    required init() {
    }
    
    func getId() -> Int {
        return self.id;
    }
    
    func getTitle() -> String {
        return self.title;
    }
    
    func getPosterPath() -> String {
        return self.posterPath;
    }
    
    func getVoteAverage() -> Float {
        return self.voteAverage;
    }
    
    func getOverview() -> String {
        return self.overview;
    }
    
    func getReleaseDate() -> String {
        return self.releaseDate;
    }
    
    func getPopularity() -> Float {
        return self.popularity;
    }
}
