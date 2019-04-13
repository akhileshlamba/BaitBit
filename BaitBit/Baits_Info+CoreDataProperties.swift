//
//  Baits_Info+CoreDataProperties.swift
//  
//
//  Created by Akhilesh Lamba on 7/4/19.
//
//

import Foundation
import CoreData


extension Baits_Info {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Baits_Info> {
        return NSFetchRequest<Baits_Info>(entityName: "Baits_Info")
    }

    @NSManaged public var laid_date: NSDate?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
//    @NSManaged public var program_id: Int64
    @NSManaged public var status: Bool
    @NSManaged public var path: String?
    @NSManaged public var program: Bait_program?

}
