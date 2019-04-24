//
//  Baits_Info+CoreDataClass.swift
//  
//
//  Created by Akhilesh Lamba on 7/4/19.
//
//

import Foundation
import CoreData


public class Baits_Info: NSManagedObject {
    var isOverdue: Bool {
        return false
    }
    
    var isDueSoon: Bool {
        return false
    }
    
    var isActive: Bool {
        return true
    }
    
    var isRemoved: Bool {
        return true
    }
}
