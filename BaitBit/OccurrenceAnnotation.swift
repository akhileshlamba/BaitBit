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
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.identifier = title
        self.subtitle = subtitle
    }
    
}
