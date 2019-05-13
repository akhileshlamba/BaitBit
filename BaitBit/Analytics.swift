//
//  Analytics.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 12/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Analytics: NSObject {

    static func averageDuration(programs: [Program]) -> Int? {
        if programs.count == 0 {
            return nil
        }
        
        return programs.reduce(0) { (result, next) -> Int in
            return result + next.durationInDays
        } / programs.count
    }
    
    static func minDuration(programs: [Program]) -> Int? {
        return programs.map({ (program) -> Int in
            return program.durationInDays
        }).min()
    }
    
    static func maxDuration(programs: [Program]) -> Int? {
        return programs.map({ (program) -> Int in
            return program.durationInDays
        }).max()
    }
    
    static func mostUsedBait(programs: [Program]) -> String? {
        let dict = Dictionary(grouping: programs) { (program) -> String in
            return program.baitType!
        }
        
        return dict.max { (left, right) -> Bool in
            return left.value.reduce(0, { (result, next) -> Int in
                return result + next.numberOfAllBaits
            }) < right.value.reduce(0, { (result, next) -> Int in
                return result + next.numberOfAllBaits
            })
        }?.key
    }
    
    static func numberOfPrograms(of baitType: String, in programs: [Program]) -> Int {
        return programs.filter({ (program) -> Bool in
            return program.baitType == baitType
        }).count
    }
    
    static func baitsTakenRate(programs: [Program]) -> Double? {
        let totalNumOfBaits = programs.reduce(0) { (result, next) -> Int in
            return result + next.numberOfAllBaits
        }
        
        if totalNumOfBaits == 0 {
            return nil
        }
        
        let totalNumOfBaitsTaken = programs.reduce(0) { (result, next) -> Int in
            return result + next.numberOfAllBaits
        }
        
        return Double(totalNumOfBaitsTaken) / Double(totalNumOfBaits)
    }
    
    static func numOfNontargetedCarcass(programs: [Program]) -> Int {
        return programs.reduce(0, { (result, next) -> Int in
            return result + next.numberOfNontargetedCarcass
        })
    }
    
    static func numOfRemovedOverdue(programs: [Program]) -> Int {
        return programs.reduce(0, { (result, next) -> Int in
            return result + next.numberOfRemovedOverdue
        })
    }
}
