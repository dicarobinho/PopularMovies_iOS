//
//  Movie.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation

class Movie: Codable {
    
    var id:Int!
    var title:String!
    var posterPath:String!
    var voteAverage:Float!
    var overview:String!
    var releaseDate:String!
    var popularity:Float!
    
//    public func getVoteAverage() -> String {
//        return self.poster_path!
//    }
}
