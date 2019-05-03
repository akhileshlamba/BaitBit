//
//  User.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class User: NSObject {

    var id: String = ""
    var licensePath: String?
    var licenseExpiryDate: NSDate? = nil
    var username: String
    var password: String
    var programs: [String: Program] = [:]
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    var daysComponentToAdd : DateComponents {
        var component = DateComponents()
        component.day = 30
        return component
    }
    
    var licenseExpiringSoon : Bool {
        let startDate = Calendar.startOfDay(Calendar.current)(for: licenseExpiryDate! as Date)
        //let dueDate = NSCalendar.current.date(byAdding: self.daysComponentToAdd, to: startDate)
        let day = Calendar.current.dateComponents([.day], from: NSDate() as Date, to: startDate).day
        
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
    
    func setId(id: String) {
        self.id = id
    }
    
    func addToPrograms(program: Program) {
        if self.programs.keys.contains(program.id) {
            return
        } else {
            self.programs[program.id] = program
        }
    }
    
    func addToPrograms(programs: [Program]) {
        for program in programs {
            addToPrograms(program: program)
        }
    }
    
}
