//
//  Program.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Program: NSObject {
    var id: String
    var baitType: String?
    var species: String?
    var startDate: NSDate?
    var isActive: Bool
    var baits: [String : Bait] = [:]
    
    init(id: String, baitType: String, species: String, startDate: NSDate, isActive: Bool) {
        self.id = id
        self.baitType = baitType
        self.species = species
        self.startDate = startDate
        self.isActive = isActive
    }
    
    func addToBaits(bait: Bait) {
        if self.baits.keys.contains(bait.id) {
            return
        } else {
            self.baits[bait.id] = bait
        }
    }
    
    func removeFromBaits(bait: Bait) -> Bait? {
        return self.baits.removeValue(forKey: bait.id)
    }
    
    var numberOfActiveBaits: Int {
        return self.baits.filter { (element) -> Bool in
            return element.value.isActive
        }.count
    }
    
    var numberOfOverdueBaits: Int {
        return self.baits.filter({ (element) -> Bool in
            return element.value.isOverdue
        }).count
    }
    
    var numberOfDueSoonBaits: Int {
        return self.baits.filter({ (element) -> Bool in
            return element.value.isDueSoon
        }).count
    }
    
    var numberOfAllBaits: Int {
        return self.baits.count
    }
    
    var numberOfUnremovedBaits: Int {
        return self.baits.filter({ (element) -> Bool in
            return !element.value.isRemoved
        }).count
    }
    
    var numberOfRemovedBaits: Int {
        return self.baits.filter({ (element) -> Bool in
            return element.value.isRemoved
        }).count
    }
    
    var hasOverdueBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
    
    var hasDueSoonBaits: Bool {
        return self.numberOfDueSoonBaits > 0
    }
}
