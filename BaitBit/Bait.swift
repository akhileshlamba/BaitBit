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
    
    var status: BaitStatus {
        // TODO: implement notification constraints
        // dueDate = laidDate + duration
        let startDate = Calendar.startOfDay(Calendar.current)(for: laidDate as Date)
        let dateComponent = componentToAdd()
        let dueDate = NSCalendar.current.date(byAdding: dateComponent, to: startDate)
        Calendar.compare
//        if self.isRemoved {
//            return .REMOVED
//        } else if NSDate() > laidDate {
//            return .OVERDUE
//        } else if NSDate() >=
        return .DUESOON
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
    
    private func componentToAdd() -> DateComponents {
        // TODO: implement notification constraints
        var component = DateComponents()
        component.day = 4 // it should be assigned according to bait type of its program
        return component
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
