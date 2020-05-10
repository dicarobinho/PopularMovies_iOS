//
//  PageMovies.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation

class PageMovies: Codable {
    
    var page:Int!
    var totalResults:Int!
    var totalPages:Int!
    var results:[Movie]!
}
