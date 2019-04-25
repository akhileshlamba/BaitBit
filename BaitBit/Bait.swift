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
    var laidDate: NSDate
    var latitude: Double
    var longitude: Double
    var photoPath: String?
    var program: Program?
    var isRemoved: Bool
    
    var removeDate : Date = Date()
    var status: BaitStatus {
        // dueDate = laidDate + duration
        let startDate = Calendar.startOfDay(Calendar.current)(for: laidDate as Date)
        let dueDate = NSCalendar.current.date(byAdding: self.program!.maximumDuration, to: startDate)
        print(dueDate)
        let day = Calendar.current.dateComponents([.day,.month], from: NSDate() as Date, to: dueDate!).day
    
        if isRemoved {
            return .REMOVED
        }
        if day! > 2 {
            return .ACTIVE
        } else if day! < 0 {
            return .OVERDUE
        } else {
            return .DUESOON
        }
    }
    
    init(id: String, laidDate: NSDate?, latitude: Double, longitude: Double, photoPath: String?, program: Program, isRemoved: Bool?) {
        self.id = id
        self.laidDate = laidDate ?? NSDate()
        self.latitude = latitude
        self.longitude = longitude
        self.photoPath = photoPath
        self.program = program
        self.isRemoved = isRemoved ?? false
    }
    
    var isOverdue: Bool {
        return status == .OVERDUE
    }
    
    var isDueSoon: Bool {
        return status == .DUESOON
    }
    
    var isActive: Bool {
        return status == .ACTIVE
    }
}
