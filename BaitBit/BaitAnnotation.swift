//
//  BaitAnnotation.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 7/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit

class BaitAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    var bait: Bait
    var title: String?
    var imageName: String {
        if !self.bait.isRemoved {
            return "\(self.bait.status)"
        }
        
        if !self.bait.isTaken! {
            return "Untouched"
        }
        
        if !self.bait.carcassFound! {
            return "Taken"
        }
        
        if self.bait.targetCarcassFound! {
            return "Targeted carcass"
        } else {
            return "Non-targeted carcass"
        }
    }
    
    init(bait: Bait) {
        self.bait = bait
        self.coordinate = CLLocationCoordinate2D(latitude: bait.latitude as! CLLocationDegrees, longitude: bait.longitude as! CLLocationDegrees)
        self.identifier = bait.program!.baitType!
        self.title = bait.program?.baitType
    }
}
