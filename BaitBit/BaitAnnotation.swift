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
    var bait_info: Baits_Info
    var title: String?
    
    init(bait_info: Baits_Info) {
        self.bait_info = bait_info
        self.coordinate = CLLocationCoordinate2D(latitude: bait_info.latitude as! CLLocationDegrees, longitude: bait_info.longitude as! CLLocationDegrees)
        self.identifier = bait_info.program!.name!
        self.title = bait_info.program!.name!
    }
}