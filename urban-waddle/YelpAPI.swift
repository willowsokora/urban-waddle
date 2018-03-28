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
            if current.distance(from: location) > 10 {
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
        let offsetItem = URLQueryItem(name: "offset", value: "\(page)")
        let radiusItem = URLQueryItem(name: "radius", value: "\(40000)")
        urlComponents.queryItems = [longitudeItem, latitudeItem, categoriesItem, offsetItem, radiusItem]
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
