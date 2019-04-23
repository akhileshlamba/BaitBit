//
//  Program.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Program: NSObject {
    var programId: Int
    var baitType: String?
    var species: String?
    var startDate: NSDate?
    var active: Bool
    var baits: [Bait]?
    
    init(programId: Int, baitType: String, species: String, startDate: NSDate) {
        self.programId = programId
        self.baitType = baitType
        self.species = species
        self.startDate = startDate
        self.active = true
    }
    
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
