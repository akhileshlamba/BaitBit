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
    var photoURL: String?
    var program: Program?
    var isRemoved: Bool
    
    var removeDate : Date = Date()
    var status: BaitStatus {
        if isRemoved {
            return .REMOVED
        }
        if self.numberOfDaysBeforeDue > 2 {
            return .ACTIVE
        } else if numberOfDaysBeforeDue < 0 {
            return .OVERDUE
        } else {
            return .DUESOON
        }
    }
    var numberOfDaysBeforeDue: Int {
        return Calendar.current.dateComponents([.day], from: NSDate() as Date, to: self.dueDate as Date).day!
    }
    var dueDate: NSDate {
        let startDate = Calendar.startOfDay(Calendar.current)(for: laidDate as Date)
        return NSCalendar.current.date(byAdding: self.program!.maximumDuration, to: startDate)! as NSDate
    }
    var durationInDays: Int {
        return Calendar.current.dateComponents([.day], from: laidDate as Date, to: NSDate() as Date).day!
    }
    
    var durationFormatted: String {
        if durationInDays <= 1 {
            return "\(durationInDays) day"
        } else {
            return "\(durationInDays) days"
        }
    }
    
    init(id: String, laidDate: NSDate?, latitude: Double, longitude: Double, photoPath: String?, photoURL: String?, program: Program, isRemoved: Bool?) {
        self.id = id
        self.laidDate = laidDate ?? NSDate()
        self.latitude = latitude
        self.longitude = longitude
        self.photoPath = photoPath
        self.photoURL = photoURL
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
