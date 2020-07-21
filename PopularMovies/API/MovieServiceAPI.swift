//
//  MovieServiceAPI.swift
//  PopularMovies
//
//  Created by Macbook on 03/05/2020.
//  Copyright © 2020 Macbook. All rights reserved.
//

import Foundation

class MovieServiceAPI {
    
    public static let shared = MovieServiceAPI()
    
    private init() {}
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let apiKey = "dfe3ff6c629370694f97eb76a8064c25"
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // Enum Endpoint
    enum Endpoint: String, CaseIterable {
        case nowPlaying = "now_playing"
        case upcoming
        case popular
        case videos = "videos"
        case reviews = "reviews"
        case topRated = "top_rated"
        case movie = "movie"
        case discover = "discover"
    }
    
    public enum APIServiceError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
    }
    
    private func fetchResources<T: Decodable>(_ page:Int, _ sortType:String, url: URL, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        if sortType == Constants.NO_TYPE {
            let queryItems = [URLQueryItem(name: "api_key", value: apiKey),URLQueryItem(name: "page", value: String(page))]
            urlComponents.queryItems = queryItems
        } else {
            let queryItems = [URLQueryItem(name: "api_key", value: apiKey),URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "sort_by", value: sortType)]
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            //            switch error {
            //            case .success(let (response, data)):
            print(url)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let values = try self.jsonDecoder.decode(T.self, from: data!)
                completion(.success(values))
            } catch {
                completion(.failure(.decodeError))
            }
            //
            //            case .failure(let error):
            //                completion(.failure(.apiError))
            //            }
        }.resume()
    }
    
    public func fetchMovies(_ page:Int, _ sortType:String, result: @escaping (Result<PageMovies, APIServiceError>) -> Void) {
        let movieURL = baseURL
            .appendingPathComponent(Endpoint.discover.rawValue)
            .appendingPathComponent(Endpoint.movie.rawValue)
        
        fetchResources(page, sortType, url: movieURL, completion: result)
    }
    
    public func fetchSpecificMovie(_ movieId:String, result: @escaping (Result<Movie, APIServiceError>) -> Void) {
        let movieURL = baseURL
            .appendingPathComponent(Endpoint.movie.rawValue)
            .appendingPathComponent(movieId)
        
        fetchResources(1, Constants.NO_TYPE, url: movieURL, completion: result)
    }
    
    public func fetchVideos(_ idMovie:String, result: @escaping (Result<PageVideos, APIServiceError>) -> Void) {
        let movieURL = baseURL
            .appendingPathComponent(Endpoint.movie.rawValue)
            .appendingPathComponent(idMovie)
            .appendingPathComponent(Endpoint.videos.rawValue)
        
        print(movieURL)
        fetchResources(1, Constants.NO_TYPE, url: movieURL, completion: result)
    }
    
    public func fetchReviews(_ idMovie:String, result: @escaping (Result<PageReviews, APIServiceError>) -> Void) {
        let movieURL = baseURL
            .appendingPathComponent(Endpoint.movie.rawValue)
            .appendingPathComponent(idMovie)
            .appendingPathComponent(Endpoint.reviews.rawValue)
        
        print(movieURL)
        fetchResources(1, Constants.NO_TYPE, url: movieURL, completion: result)
    }
}
