//
//  YelpAPI.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//

import Foundation
import CoreLocation

internal let API_KEY = "ubCA-5lUpYwjxko_J6A7lrTMDgtIECjkW_lVYgk632b5nPkTtAMbpAWO94BVwKd_dkcCrSQZ4IGEGTsyxUIPvUdLSBSBQL4MLje-nzyfr5ZzL_meBMaoszPw4aGUWnYx"

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

struct YelpAPI {
    
    static var page = 0
    static var currentLocation: CLLocation?
    
    static func getRestaurants(near location: CLLocation, completion: ((Result<YelpSearch>) -> Void)?) {
        if let current = currentLocation {
            if current.distance(from: location) > 2000 {
                currentLocation = location
                page = 0
            } else {
                page += 1
            }
        } else {
            currentLocation = location
            page = 0
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        urlComponents.path = "/v3/businesses/search"
        let longitudeItem = URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)")
        let latitudeItem = URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)")
        let categoriesItem = URLQueryItem(name: "categories", value: "restaurants")
        let offsetItem = URLQueryItem(name: "offset", value: "\(page * 50 + 1)")
        let radiusItem = URLQueryItem(name: "radius", value: "\(40000)")
        let limitItem = URLQueryItem(name: "limit", value: "\(50)")
        urlComponents.queryItems = [longitudeItem, latitudeItem, categoriesItem, offsetItem, radiusItem, limitItem]
        guard let url = urlComponents.url else {
            fatalError("Could not create url from components")
        }
        //print("\(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(API_KEY)"]
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    //print(NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue))
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(YelpSearch.self, from: jsonData)
                        completion?(.success(results))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    static func search(near location: CLLocation, term: String, completion: ((Result<YelpSearch>) -> Void)?) {
//        if let current = currentLocation {
//            if current.distance(from: location) > 2000 {
//                currentLocation = location
//                page = 0
//            } else {
//                page += 1
//            }
//        } else {
//            currentLocation = location
//            page = 0
//        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        urlComponents.path = "/v3/businesses/search"
        let longitudeItem = URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)")
        let latitudeItem = URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)")
        let categoriesItem = URLQueryItem(name: "categories", value: "restaurants")
//        let offsetItem = URLQueryItem(name: "offset", value: "\(page)")
        let radiusItem = URLQueryItem(name: "radius", value: "\(40000)")
        let limitItem = URLQueryItem(name: "limit", value: "\(50)")
        let termItem = URLQueryItem(name: "term", value: term)
        urlComponents.queryItems = [longitudeItem, latitudeItem, categoriesItem, radiusItem, limitItem, termItem]
        guard let url = urlComponents.url else {
            fatalError("Could not create url from components")
        }
        print("\(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(API_KEY)"]
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    //print(NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue))
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(YelpSearch.self, from: jsonData)
                        completion?(.success(results))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    static func getDetails(for restaurant: String, completion: ((Result<YelpRestaurantDetails>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        urlComponents.path = "/v3/businesses/\(restaurant)"
        guard let url = urlComponents.url else {
            fatalError("Could not create url from components")
        }
        print("\(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(API_KEY)"]
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    //print(NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue))
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(YelpRestaurantDetails.self, from: jsonData)
                        completion?(.success(results))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct YelpRestaurantDetails: Codable {
    let id: String
    let alias: String
    let name: String
    let imageUrl: String
    let isClaimed: Bool
    let isClosed: Bool
    let url: String
    let price: String
    let rating: Double
    let reviewCount: Int
    let phone: String
    let photos: [String]
    let categories: [YelpCategory]
    let coordinates: YelpCoordinates
    let location: YelpLocation
    let transactions: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, alias, name, url, price, rating, phone, photos, categories, coordinates, location, transactions
        case imageUrl = "image_url"
        case isClaimed = "is_claimed"
        case isClosed = "is_closed"
        case reviewCount = "review_count"
    }
}

struct YelpHours: Codable {
    let hoursType: String
    let open: [YelpHoursDetails]
    let isOpenNow: String
    
    enum CodingKeys: String, CodingKey {
        case open
        case hoursType = "hours_type"
        case isOpenNow = "is_open_now"
    }
}

struct YelpHoursDetails: Codable {
    let isOvernight: Bool
    let start: String
    let end: String
    let day: Int
    
    enum CodingKeys: String, CodingKey {
        case start, end, day
        case isOvernight = "is_overnight"
    }
}

struct YelpSearch: Codable {
    let total: Int
    let businesses: [YelpRestaurant]
    let region: YelpRegion
}

struct YelpRestaurant: Codable {
    let rating: Double
    let price: String?
    let phone: String
    let id: String
    let isClosed: Bool
    let categories: [YelpCategory]
    let reviewCount: Int
    let name: String
    let url: String
    let coordinates: YelpCoordinates
    let imageUrl: String
    let location: YelpLocation
    let distance: Double
    let transactions: [String]
    
    enum CodingKeys: String, CodingKey {
        case rating, price, phone, id, categories, name, url, coordinates, location, distance, transactions
        case isClosed = "is_closed"
        case reviewCount = "review_count"
        case imageUrl = "image_url"
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let city: String
    let country: String
    let address1: String
    let address2: String?
    let address3: String?
    let state: String
    let zipCode: String
    
    enum CodingKeys: String, CodingKey {
        case city, country, address1, address2, address3, state
        case zipCode = "zip_code"
    }
}

struct YelpRegion: Codable {
    let center: YelpCoordinates
}
