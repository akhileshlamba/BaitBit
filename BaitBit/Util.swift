//
//  Util.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    static var formatter = DateFormatter()
    static let dateFormat = "MMM dd, yyyy"
    
    
    static func setDateAsString(date: NSDate) -> String {
        formatter.dateFormat = dateFormat
        return formatter.string(from: date as! Date)
    }
    
    static func convertStringToDate(string: String) -> NSDate {
        formatter.dateFormat = dateFormat
        return formatter.date(from: string) as! NSDate
    }

}
