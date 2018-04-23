//
//  Restaurant+CoreDataProperties.swift
//  urban-waddle
//
//  Created by Jacob Sokora on 4/22/18.
//  Copyright © 2018 waddlers. All rights reserved.
//
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var rawStatus: Int16
    @NSManaged public var url: String?
    @NSManaged public var yelpId: String?
    @NSManaged public var yelpPrice: String?
    @NSManaged public var yelpRating: Double
    @NSManaged public var tags: NSSet?

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
