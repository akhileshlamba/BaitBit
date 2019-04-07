//
//  Bait_program+CoreDataProperties.swift
//  
//
//  Created by Akhilesh Lamba on 6/4/19.
//
//

import Foundation
import CoreData


extension Bait_program {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bait_program> {
        return NSFetchRequest<Bait_program>(entityName: "Bait_program")
    }

    @NSManaged public var name: String?
    @NSManaged public var start_date: NSDate?
    @NSManaged public var duration: Int
    @NSManaged public var baits_limit: Int
    @NSManaged public var baits: NSSet?
    @NSManaged public var active: Bool

}

// MARK: Generated accessors for baits
extension Bait_program {

    @objc(addBaitsObject:)
    @NSManaged public func addToBaits(_ value: Baits_Info)

    @objc(removeBaitsObject:)
    @NSManaged public func removeFromBaits(_ value: Baits_Info)

    @objc(addBaits:)
    @NSManaged public func addToBaits(_ values: NSSet)

    @objc(removeBaits:)
    @NSManaged public func removeFromBaits(_ values: NSSet)

}
