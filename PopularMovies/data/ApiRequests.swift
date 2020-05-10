//
//  ApiRequests.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation

class ApiRequests {
    
    func getDataFromApi(_ url:String) -> dictionary {
        // URL
        let url = URL(string: url)
        
        // URL can be nil, so we should check it
        guard url != nil else {
            print("Error creating url object")
            return
        }
        
    }
//
//
//    // URL Request
//    var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
//
//    // Specify the header
//    let header = ["x-rapidapi-host": "ocr-text-extractor.p.rapidapi.com", "x-rapidapi-key": "4709t2ffiw022938hr2084hew0fhwefwhwef", "accept": "string", "content-type": "application/json"]
//
//    request.allHTTPHeaderFields = header
//
//    // Specify the body
//    let jsonObject  = ["Uri": "https://fsdfsdfsdfsfsfsf", "Language": "eng"] as [String:Any]
//
//    do{
//
//        let requestBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
//
//        request.httpBody = requestBody
//    }
//    catch {
//        print("Error creating the data from the json object")
//    }
//
//    // Set the reques type
//    request.httpMethod = "POST"
//
//    // Get the URL session
//    let session = URLSession.shared
//
//    // Create data task
//    let dataTask = session.dataTask(with: request) { (data, response, error) in
//
//        // Check for Error
//        if error == nil && data != nil {
//
//            // parse data
//
//            do {
//
//                let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
//
//                print(dictionary)
//            }
//            catch {
//                print("Error parsing response data")
//            }
//        }
//    }
//
//    // Fire off the data task
//    dataTask.resume()
}
