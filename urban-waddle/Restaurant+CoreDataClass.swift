//
//  Restaurant+CoreDataClass.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 3/27/18.
//  Copyright © 2018 waddlers. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

public class Restaurant: NSManagedObject {
    public enum Status: Int16 {
        case uninterested = 0
        case interested = 1
        case disliked = 2
        case liked = 3
    }

    @NSManaged public var name: String
    @NSManaged public var note: String?
    @NSManaged public var yelpId: String
    @NSManaged public var yelpPrice: String?
    @NSManaged public var yelpRating: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    public var rawStatus: Int16 {
        get {
            willAccessValue(forKey: "rawStatus")
            defer { didAccessValue(forKey: "rawStatus") }
            
            return primitiveValue(forKey: "rawStatus") as! Int16
        }
        set {
            willChangeValue(forKey: "rawStatus")
            defer { didChangeValue(forKey: "rawStatus") }

            setPrimitiveValue(newValue, forKey: "rawStatus")
        }
    }
    
    public var status: Status {
        get {
            return Status(rawValue: rawStatus) ?? .uninterested
        }
        set {
            rawStatus =  newValue.rawValue
        }
    }
    
    @nonobjc func loadData(from yelpRestaurant: YelpRestaurant, with status: Status) {
        loadData(from: yelpRestaurant, with: status, note: nil)
    }
    
    @nonobjc func loadData(from yelpRestaurant: YelpRestaurant, with status: Status, note: String?) {
        self.status = status
        self.name = yelpRestaurant.name
        self.note = note
        self.yelpId = yelpRestaurant.id
        self.yelpPrice = yelpRestaurant.price ?? ""
        self.yelpRating = yelpRestaurant.rating
        self.latitude = yelpRestaurant.coordinates.latitude
        self.longitude = yelpRestaurant.coordinates.longitude
    }
    
    @nonobjc func distance(to: CLLocation) -> Double {
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        return to.distance(from: fromLocation)
    }
}
