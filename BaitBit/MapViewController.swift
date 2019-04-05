//
//  MapViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 1/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    let databaseRef: DatabaseReference = Database.database().reference().child("invasive_species")
    var occurrenceAnnotations: [OccurrenceAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        loadData(species: "vulpes")
        
    }

    // This method is to load data from remote dataset
    func loadData(species: String) {
        self.databaseRef.child(species).observeSingleEvent(of: .value) { (snapshot) in
            guard let dataset = snapshot.value as? NSArray else {
                return
            }
            
            self.occurrenceAnnotations.removeAll()
            for record in dataset {
                let record = record as! NSDictionary
                let lat = record["Latitude"] as! Double
                let long = record["Longitude"] as! Double
                let month = record["Month"] as! Int
                let year = record["Year"] as! Int
                let occurrence = OccurrenceAnnotation(title: species, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), subtitle: "\(year) - \(month)")
                self.occurrenceAnnotations.append(occurrence)
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.occurrenceAnnotations)
            
        }
    }
    
    // MARK: - Manage Annotations
    
    func addAnnotation(annotation: MKAnnotation) {
        guard let annotation = annotation as? OccurrenceAnnotation else { return }
        self.mapView.addAnnotation(annotation)
        
//        // Set up Geofence
//        geoLocation = annotation.geoLocation
//        geoLocation!.notifyOnExit = true
//        geoLocation!.notifyOnEntry = true
        
        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.startMonitoring(for: geoLocation!)
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        print("\(String(describing: annotation.title!)) is added.") // this line is just for debugging
    }
    
    func removeAnnotation(annotation: MKAnnotation) {
        guard let annotation = annotation as? OccurrenceAnnotation else { return }
        self.mapView.removeAnnotation(annotation)
//        self.locationManager.stopMonitoring(for: annotation.geoLocation)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    func focusOn(annotation: MKAnnotation) {
        
        self.mapView.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500)
        self.mapView.selectAnnotation(annotation, animated: true)
        
//        if let annotation = annotation as? OccurrenceAnnotation {
//            self.mapView.removeOverlays(self.mapView.overlays)
//            let circle: MKCircle = MKCircle(center: annotation.geoLocation.center, radius: annotation.geoLocation.radius)
//            self.mapView.add(circle)
//        }
    }
    
    // This method is to keep track of the user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 400, 400)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
