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
        self.subtitle = "\(year) - \(month)"
    }
    
    func isWithin(year: String) -> Bool {
        if year == "" {
            return true
        } else {
            return self.year == Int(year)
        }
    }
    
    func isWithin(month: String) -> Bool {
        if month == "" {
            return true
        } else {
            return self.month == Int(month)
        }
    }
    
    func isWithin(species: String) -> Bool {
        if species == "" {
            return true
        } else {
            return self.title == species
        }
    }
    
}
