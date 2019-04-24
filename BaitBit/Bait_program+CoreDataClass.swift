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
        // TODO: implement number of active baits for a program
        return 0
    }
    
    var numberOfOverdueBaits: Int {
        // TODO: implement number of overdue baits for a program
        return 0
    }
    
    var numberOfDueSoonBaits: Int {
        // TODO: implement number of due soon baits for a program
        return 0
    }
    
    var numberOfAllBaits: Int {
        return self.baits!.count
    }
    
    var numberOfUnremovedBaits: Int {
        // TODO: implement number of unremoved baits for a program
        return 0
    }
    
    var hasOverdueBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
    
    var hasDueSoonBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
}
