//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Jay Gabriel on 10/23/17.
//  Copyright © 2017 Jay Gabriel. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var pin: Pin?

}
