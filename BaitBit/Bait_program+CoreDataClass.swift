//
//  Bait_program+CoreDataClass.swift
//  
//
//  Created by Akhilesh Lamba on 7/4/19.
//
//

import Foundation
import CoreData


public class Bait_program: NSManagedObject {
    var numberOfActiveBaits: Int {
        return 0
    }
    
    var numberOfOverdueBaits: Int {
        return 0
    }
    
    var numberOfDueSoonBaits: Int {
        return 0
    }
    
    var numberOfAllBaits: Int {
        return self.baits!.count
    }
    
    var hasOverdueBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
    
    var hasDueSoonBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
}
