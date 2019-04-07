//
//  Baits_Info+CoreDataProperties.swift
//  
//
//  Created by Akhilesh Lamba on 6/4/19.
//
//

import Foundation
import CoreData


extension Baits_Info {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Baits_Info> {
        return NSFetchRequest<Baits_Info>(entityName: "Baits_Info")
    }

    @NSManaged public var program_id: Int32
    @NSManaged public var laid_date: NSDate
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var program: Bait_program?

}
