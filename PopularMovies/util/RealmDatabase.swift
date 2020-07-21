//
//  RealmDatabase.swift
//  PopularMovies
//
//  Created by Alex Farcasanu on 30/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabase {
    
    //adaugare film favorit in baza de date
    static func addMovieToDb(_ realm: Realm, _ movie: Movie) {
        try! realm.write {
            realm.add(movie)
        }
        
        displayDatabasePath()
    }
    
    //stergere film favorit din baza de date
    static func deleteMovieFromDb(_ realm: Realm, _ movie: Movie) {
        try! realm.write {
            realm.delete(realm.objects(Movie.self).filter("title=%@", movie.getTitle()))
        }
        
        displayDatabasePath()
    }
    
    static func verifyIfMovieExistInDb(_ realm: Realm, _ title: String) -> Bool {
        
        let results = realm.objects(Movie.self).filter("title=%@", title)
        
        if results.count != 0 {
            return true
        } else {
            return false
        }
    }
    
    static func verifyIfDbIsClear(_ realm: Realm) -> Bool{
        let results = realm.objects(Movie.self)
        
        if results.count != 0 {
            return false
        } else {
            return true
        }
    }
    
    static func getAllMoviesFromDb(_ realm: Realm) -> Results<Movie> {
        let results = realm.objects(Movie.self)
        
        return results
    }
    
    static func displayDatabasePath() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
}
