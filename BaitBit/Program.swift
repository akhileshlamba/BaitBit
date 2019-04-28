//
//  Program.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

//enum BaitType: String, CaseIterable {
//    case Shelf_stable_rabbit_bait = "Shelf-stable Rabbit Bait"
//    case Shelf_stable Feral Pig Bait = "Shelf-stable Feral Pig Bait"
//    case Shelf_stable Fox or Wild Dog Bait = "Shelf-stable Fox or Wild Dog Bait"
//    case Fox_or_Wild_Dog_capsule = "Fox or Wild Dog capsule"
//    case Perishable Fox Bait = "Perishable Fox Bait"
//    case Perishable Wild Dog Bait = "Perishable Wild Dog Bait"
//    case Perishable Rabbit Bait = "Perishable Rabbit Bait"
//}
enum BaitType: String, CaseIterable {
    case Shelf_Rabbit = "Shelf-stable Rabbit Bait (oat)"
    case Shelf_Pig = "Shelf-stable Feral Pig Bait"
    case Shelf_Fox_Dog = "Shelf-stable Fox or Wild Dog Bait"
    case Capsule_Fox_Dog = "Fox or Wild Dog Capsules"
    case Perishable_Fox = "Perishable Fox Bait (liver)"
    case Perishable_Dog = "Perishable Wild Dog Bait (liver or boneless red meat)"
    case Perishable_Rabbit = "Perishable Rabbit Bait (carrot)"

}

let BaitTypeDuration = [
    BaitType.Shelf_Rabbit.rawValue: 4,
    BaitType.Shelf_Pig.rawValue: 7,
    BaitType.Shelf_Fox_Dog.rawValue: 30,
    BaitType.Capsule_Fox_Dog.rawValue: 60,
    BaitType.Perishable_Fox.rawValue: 7,
    BaitType.Perishable_Dog.rawValue: 14,
    BaitType.Perishable_Rabbit.rawValue: 4
]

class Program: NSObject {
    static var program: Program?
    var id: String
    var baitType: String?
    var species: String?
    var startDate: NSDate
    var isActive: Bool
    var baits: [String : Bait] = [:]
    var maximumDuration: DateComponents {
        var component = DateComponents()
        component.day = BaitTypeDuration[self.baitType!]
        return component
    }
    
    var documents : [Documents!] = []
    
    init(id: String, baitType: String, species: String, startDate: NSDate?, isActive: Bool?) {
        self.id = id
        self.baitType = baitType
        self.species = species
        self.startDate = startDate ?? NSDate()
        self.isActive = isActive ?? true
    }
    
    func addToBaits(bait: Bait) {
        if self.baits.keys.contains(bait.id) {
            return
        } else {
            self.baits[bait.id] = bait
        }
    }
    
    func addToBaits(baits: [Bait]) {
        for bait in baits {
            addToBaits(bait: bait)
        }
    }
    
    func removeFromBaits(bait: Bait) -> Bait? {
        return self.baits.removeValue(forKey: bait.id)
    }
    
    var durationInDays: Int {
        return Calendar.current.dateComponents([.day, .month], from: startDate as Date, to: NSDate() as Date).day!
    }
    
    var durationFormatted: String {
        return "\(durationInDays) day(s)"
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
    
    func addToDocuments(document: Documents){
        self.documents.append(document)
    }
}
