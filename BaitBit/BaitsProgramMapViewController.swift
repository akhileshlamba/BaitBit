//
//  BaitsProgramMapViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit

class BaitsProgramMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    var program: Bait_program!
    
    var baitsLocationAnnotation: [OccurrenceAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.program)
        loadData()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadData() {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        self.baitsLocationAnnotation.removeAll()
//        for species in dataSource {
//            self.databaseRef.child(species).observeSingleEvent(of: .value) { (snapshot) in
//                guard let dataset = snapshot.value as? NSArray else {
//                    return
//                }
//
//                for record in dataset {
//                    let record = record as! NSDictionary
//                    let lat = record["Latitude"] as! Double
//                    let long = record["Longitude"] as! Double
//                    let month = record["Month"] as! Int
//                    let year = record["Year"] as! Int
//                    let occurrence = OccurrenceAnnotation(title: species, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), subtitle: "\(year) - \(month)")
//                    self.occurrenceAnnotations.append(occurrence)
//                }
//                self.mapView.addAnnotations(self.occurrenceAnnotations)
//            }
//        }
        
    }
    
    // This method is to keep track of the user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 40000, 40000)
        self.mapView.setRegion(viewRegion, animated: true)
        
        let annotation = PinAnnotation(coordinate: currentLocation, identifier: "currentLocation")
        self.mapView.addAnnotation(annotation)
        //        focusOn(annotation: annotation)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annoationView = MKAnnotationView()
        
        if let fencedAnnotation = annotation as? OccurrenceAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: fencedAnnotation.identifier) {
                annoationView = dequeuedView
            } else {
                annoationView = MKAnnotationView(annotation: fencedAnnotation, reuseIdentifier: fencedAnnotation.identifier)
            }
            
            annoationView.image = UIImage(named: fencedAnnotation.identifier)
            annoationView.canShowCallout = true
            annoationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
            return annoationView
        } else if let myLocationAnnotation = annotation as? PinAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: myLocationAnnotation.identifier) {
                annoationView = dequeuedView
            } else {
                annoationView = MKAnnotationView(annotation: myLocationAnnotation, reuseIdentifier: myLocationAnnotation.identifier)
            }
            
            annoationView.image = UIImage(named: "pin")
        }
        
        
        return annoationView
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
