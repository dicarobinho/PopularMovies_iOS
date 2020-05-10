//
//  PageReviews.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation

class PageReviews: Codable {
    
    var page:Int?
    var id:Int?
    var results:[Review]
}
