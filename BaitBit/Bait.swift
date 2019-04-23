//
//  Bait.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

enum BaitStatus: Int, CaseIterable {
    case ACTIVE, OVERDUE, DUESOON, REMOVED
}

class Bait: NSObject {
    
    var id: String
    var laidDate: NSDate?
    var latitude: Double
    var longitude: Double
    var photoPath: String?
    var program: Program?
    var status: BaitStatus
    
    init(id: String, laidDate: NSDate, latitude: Double, longitude: Double, photoPath: String, program: Program, status: BaitStatus) {
        self.id = id
        self.laidDate = laidDate
        self.latitude = latitude
        self.longitude = longitude
        self.photoPath = photoPath
        self.program = program
        self.status = status
    }
    
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
