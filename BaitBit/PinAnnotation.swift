//
//  PinAnnotation.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 5/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, title: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.title = title
    }
}
