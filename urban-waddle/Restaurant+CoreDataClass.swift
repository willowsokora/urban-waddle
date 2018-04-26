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
import UIKit

let statusColors: [UIColor]  = [UIColor(red: 0, green: 0.56, blue: 0.31, alpha: 1), .lightGray, .red]

public class Restaurant: NSManagedObject {
    
    public enum Status: Int16 {
        case liked = 0
        case interested = 1
        case disliked = 2
        case uninterested = 3
    }

    @NSManaged public var name: String
    @NSManaged public var note: String?
    @NSManaged public var yelpId: String
    @NSManaged public var yelpPrice: String
    @NSManaged public var yelpRating: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var phoneNumber: String
    @NSManaged public var address: String
    @NSManaged public var url: String
    @NSManaged public var city: String
    
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
    
    @NSManaged public var tags: NSSet?
    
    public var statusColor: UIColor {
        return statusColors[Int(rawStatus)]
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
        self.phoneNumber = yelpRestaurant.phone
        self.address = yelpRestaurant.location.address1
        self.url = yelpRestaurant.url
        self.city = yelpRestaurant.location.city
        self.addToTags(NSSet(array: getTags(from: yelpRestaurant.categories)))
    }
    
    @nonobjc func loadData(fromDetails yelpRestaurant: YelpRestaurantDetails, with status: Status) {
        loadData(fromDetails: yelpRestaurant, with: status, note: nil)
    }
    
    @nonobjc func loadData(fromDetails yelpRestaurant: YelpRestaurantDetails, with status: Status, note: String?) {
        self.status = status
        self.name = yelpRestaurant.name
        self.note = note
        self.yelpId = yelpRestaurant.id
        self.yelpPrice = yelpRestaurant.price
        self.yelpRating = yelpRestaurant.rating
        self.latitude = yelpRestaurant.coordinates.latitude
        self.longitude = yelpRestaurant.coordinates.longitude
        self.phoneNumber = yelpRestaurant.phone
        self.address = yelpRestaurant.location.address1
        self.url = yelpRestaurant.url
        self.city = yelpRestaurant.location.city
        self.addToTags(NSSet(array: getTags(from: yelpRestaurant.categories)))
    }
    
    @nonobjc func distance(to: CLLocation) -> Double {
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        return to.distance(from: fromLocation)
    }
    
    @nonobjc func getTags(from categories: [YelpCategory]) -> [Tag] {
        var tags = [Tag]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSRollbackMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)
        for category in categories {
            let tag = Tag(entity: entity!, insertInto: context)
            tag.title = category.title
            tags.append(tag)
        }
        return tags
    }
    
    @nonobjc static func add(restaurant: YelpRestaurant, status: Restaurant.Status) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSRollbackMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: context)
        let data = Restaurant(entity: entity!, insertInto: context)
        data.loadData(from: restaurant, with: status)
        do {
            try context.save()
        } catch {
            print("Failed to add restaurant: \(error.localizedDescription)")
        }
       
    }
    
    @nonobjc static func add(restaurant: YelpRestaurantDetails, status: Restaurant.Status) -> Restaurant {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSRollbackMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: context)
        let data = Restaurant(entity: entity!, insertInto: context)
        data.loadData(fromDetails: restaurant, with: status)
        do {
            try context.save()
        } catch {
            print("Failed to add restaurant: \(error.localizedDescription)")
        }
        return data
    }
    
    @nonobjc static func remove(restaurant yelpRestaurant: YelpRestaurant) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.mergePolicy = NSOverwriteMergePolicy
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.yelpId == yelpRestaurant.id {
                    context.delete(restaurant)
                    try context.save()
                    return
                }
            }
        } catch {
            print("Failed to delete restaurant: \(error.localizedDescription)")
        }
    }
    
    @nonobjc static func remove(restaurant: Restaurant) {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.mergePolicy = NSOverwriteMergePolicy
            context.delete(restaurant)
            try context.save()
        } catch {
            print("Failed to delete restaurant: \(error.localizedDescription)")
        }
    }
    
    @nonobjc static func getAllInterestedRestaurantsUnfiltered() -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status != .uninterested {
                    restaurants.append(restaurant)
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllInterestedRestaurants() -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        
        let store = UserDefaults.standard
        let tagFilters = store.stringArray(forKey: "SavedTagArray") ?? []
        let priceFilters = store.stringArray(forKey: "SavedPricesArray") ?? []
        let cityFilters = store.stringArray(forKey: "SavedCitiesArray") ?? []
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status != .uninterested {
                    var include = false
                    if tagFilters.count > 0 {
                        for tag in restaurant.tags?.allObjects as! [Tag] {
                            if tagFilters.contains(tag.title!) {
                                include = true
                            }
                        }
                    } else {
                        include = true
                    }
                    if cityFilters.count > 0 {
                        include = include && cityFilters.contains(restaurant.city)
                    }
                    if priceFilters.count > 0  {
                        include = include && priceFilters.contains(restaurant.yelpPrice)
                    }
                    if include {
                        restaurants.append(restaurant)
                    }
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllInterestedRestaurantsSeparated() -> [[Restaurant]] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants: [[Restaurant]] = [[], [], []]
        
        let store = UserDefaults.standard
        let tagFilters = store.stringArray(forKey: "SavedTagArray") ?? []
        let priceFilters = store.stringArray(forKey: "SavedPricesArray") ?? []
        let cityFilters = store.stringArray(forKey: "SavedCitiesArray") ?? []
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status != .uninterested {
                    var include = false
                    if tagFilters.count > 0 {
                        for tag in restaurant.tags?.allObjects as! [Tag] {
                            if tagFilters.contains(tag.title!) {
                                include = true
                            }
                        }
                    } else {
                        include = true
                    }
                    if cityFilters.count > 0 {
                        include = include && cityFilters.contains(restaurant.city)
                    }
                    if priceFilters.count > 0  {
                        include = include && priceFilters.contains(restaurant.yelpPrice)
                    }
                    if include {
                        restaurants[Int(restaurant.rawStatus)].append(restaurant)
                    }
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllNonInterestedRestaurants() -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.status == .uninterested {
                    restaurants.append(restaurant)
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func getAllSavedIds() -> [String] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurantIds = [String]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                restaurantIds.append(restaurant.yelpId)
            }
        } catch {
            print("Failed to load data")
        }
        return restaurantIds
    }
    
    @nonobjc static func search(term: String) -> [Restaurant] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var restaurants = [Restaurant]()
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            for restaurant in results as! [Restaurant] {
                if restaurant.name.contains(term) {
                    restaurants.append(restaurant)
                } else {
//                    for category in restaurant.tags.components(separatedBy: ",") {
//                        if category.contains(term) {
//                            restaurants.append(restaurant)
//                            break
//                        }
//                    }
                }
            }
        } catch {
            print("Failed to load data")
        }
        return restaurants
    }
    
    @nonobjc static func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
}

// MARK: Generated accessors for tags
extension Restaurant {
    
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
    
}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
