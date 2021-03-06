//
//  OccurrenceAnnotation.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 5/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit

class OccurrenceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    var title: String?
    var subtitle: String?
    var year: Int
    var month: Int
    
    init(title: String, coordinate: CLLocationCoordinate2D, year: Int, month: Int) {
        self.coordinate = coordinate
        self.title = title
        self.identifier = title
        self.year = year
        self.month = month
        let m = "\(Month.init(rawValue: month)!)"
        let mmm = String(m.prefix(3))
        self.subtitle = "\(year) \(mmm)"
    }
    
    func isWithin(year: Int) -> Bool {
        if year == 0 {
            return true
        } else {
            return self.year == year
        }
    }
    
    func isWithin(month: Int) -> Bool {
        if month == 0 {
            return true
        } else {
            return self.month == month
        }
    }
    
    func isWithin(species: Int) -> Bool {
        if species == 0 {
            return true
        } else {
            return self.title == "\(Species.allCases[species - 1])"
        }
    }
    
}
