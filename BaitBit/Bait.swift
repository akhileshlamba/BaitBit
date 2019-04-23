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
