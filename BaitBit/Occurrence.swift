//
//  Occurrence.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 4/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit

class Occurrence: NSObject {
    var latitude: Double
    var longitude: Double
    var eventDate: NSDate?
    var species: String?
    
    init(latitude: Double, longitude: Double, eventDate: NSDate, species: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.eventDate = eventDate
        self.species = species
    }
}
