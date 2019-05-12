//
//  CompletedProgramsMapViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 12/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import MapKit

class CompletedProgramsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var currentLocation = CLLocationCoordinate2D(latitude: -37.87763, longitude: 145.045374)
    var locationManager: CLLocationManager = CLLocationManager()
    var program: Program?
    var baits: [Bait] = []
    var selectedBait: Bait?
    var filters: (startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool)?

    var baitAnnotations: [BaitAnnotation] = []
    var filteredBaitAnnotations: [BaitAnnotation] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
