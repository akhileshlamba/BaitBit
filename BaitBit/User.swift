//
//  User.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class User: NSObject {

    var id: String
    var licensePath: String?
    var licenseExpiryDate: NSDate?
    var username: String
    var password: String
    var program: Program?
    
    init(id: String, licensePath: String?, licenseExpiryDate: NSDate, username: String, password: String, program: Program?) {
        self.id = id
        self.licensePath = licensePath
        self.licenseExpiryDate = licenseExpiryDate
        self.username = username
        self.password = password
        self.program = program
    }
    
    var daysComponentToAdd : DateComponents {
        var component = DateComponents()
        component.day = 30
        return component
    }
    
    var licenseExpiringSoon : Bool {
        let startDate = Calendar.startOfDay(Calendar.current)(for: licenseExpiryDate! as Date)
        let dueDate = NSCalendar.current.date(byAdding: self.daysComponentToAdd, to: startDate)
        let day = Calendar.current.dateComponents([.day], from: NSDate() as Date, to: dueDate!).day
        
        if day! > 30 {
            return false
        } else {
            return true
        }
    }
    
    func setLicensePath(path: String){
        self.licensePath = path
    }
    
    func setLicenseExpiryDate(date: NSDate){
        self.licenseExpiryDate = date
    }
}
