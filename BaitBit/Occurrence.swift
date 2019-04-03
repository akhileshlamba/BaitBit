//
//  Occurrence.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 4/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit

class Occurrence: NSObject {
    var location: CLLocationCoordinate2D?
    var eventDate: NSDate?
    var species: String?
    
    init(location: CLLocationCoordinate2D, eventDate: NSDate, species: String) {
        self.location = location
        self.eventDate = eventDate
        self.species = species
    }
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, eventDate: NSDate, species: String) {
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.eventDate = eventDate
        self.species = species
    }
}
