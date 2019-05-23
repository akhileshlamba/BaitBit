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

protocol FilterUpdateDelegate {
    func updateData(yearIndex: Int, monthIndex: Int, speciesIndex: Int)
}

enum Species: String, CaseIterable {
    case Foxes = "vulpes"
    case Rabbits = "rabbits"
    case Dogs = "dogs"
    case Pigs = "pigs"
    
    var identifier: Int {
        switch self {
        case .Foxes:
            return 1
        case .Rabbits:
            return 2
        case .Dogs:
            return 3
        case .Pigs:
            return 4
        }
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, FilterUpdateDelegate {

//    override var prefersStatusBarHidden: Bool {
//        return self.navigationController!.isNavigationBarHidden
//    }
    
    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D(latitude: -37.87763, longitude: 145.045374)
    var locationManager: CLLocationManager = CLLocationManager()
    let databaseRef: DatabaseReference = Database.database().reference().child("invasive_species")
    var occurrenceAnnotations: [OccurrenceAnnotation] = []
    var selectedYearIndex: Int = 0
    var selectedMonthIndex: Int = 0
    var selectedSpeciesIndex: Int = 0
    @IBOutlet weak var backToCurrentLocationButton: UIButton!
    var lastRegion: MKCoordinateRegion?
    
    var isTrackingCurrentLoc: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItems()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        loadData()
        
        
//        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 4000, 4000)
//        self.mapView.setRegion(viewRegion, animated: true)
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 400000, 400000), animated: false)

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapping))
        self.view.addGestureRecognizer(tap)

    }
    
    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Invasive Species Map"
    }
    
    
    @IBAction func backToCurrentLocation(_ sender: UIButton) {
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude), 4000, 4000), animated: true)
        self.isTrackingCurrentLoc = true
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItems()
        if let region = self.lastRegion {
            self.mapView.setRegion(region, animated: true)
        } else {
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 400000, 400000), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.lastRegion = self.mapView.region
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isTrackingCurrentLoc = false
    }
    
    @objc func tapping() {
//        if self.navigationController!.isNavigationBarHidden {
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//        } else {
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//        }
//        self.backToCurrentLocationButton.isHidden = !self.backToCurrentLocationButton.isHidden
    }
    
    // This method is to load data from remote dataset
    func updateData(yearIndex: Int, monthIndex: Int, speciesIndex: Int) {
        // remove all annotations, leave only the current location annotation
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: Date())
        
        let filteredAnnotations = occurrenceAnnotations.filter { (annotation) -> Bool in
            return annotation.isWithin(year: Int(currentYear)! - yearIndex) && annotation.isWithin(month: monthIndex) && annotation.isWithin(species: speciesIndex)
        }
        self.mapView.addAnnotations(filteredAnnotations)
        
        self.selectedYearIndex = yearIndex
        self.selectedMonthIndex = monthIndex
        self.selectedSpeciesIndex = speciesIndex
    }
    
    func loadData() {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        self.occurrenceAnnotations.removeAll()
        for species in Species.allCases {
            self.databaseRef.child(species.rawValue).observeSingleEvent(of: .value) { (snapshot) in
                guard let dataset = snapshot.value as? NSArray else {
                    return
                }
                
                for record in dataset {
                    let record = record as! NSDictionary
                    let lat = record["Latitude"] as! Double
                    let long = record["Longitude"] as! Double
                    let month = record["Month"] as! Int
                    let year = record["Year"] as! Int
                    let occurrence = OccurrenceAnnotation(title: "\(species)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), year: year, month: month)
                    self.occurrenceAnnotations.append(occurrence)
                }
                self.mapView.addAnnotations(self.occurrenceAnnotations)
                
                self.updateData(yearIndex: 0, monthIndex: 0, speciesIndex: 0)
            }
        }
    }
    
    // This method is to keep track of the user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        if self.isTrackingCurrentLoc {
            self.mapView.setCenter(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), animated: true)
        }
        let annotations = mapView.annotations
        for annotation in annotations {
            if annotation is PinAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
        let annotation = PinAnnotation(coordinate: currentLocation, identifier: "currentLocation", title: "You are here")
        self.mapView.addAnnotation(annotation)
//        focusOn(annotation: annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FilterSegue" {
            let controller = segue.destination as! FilterViewController
            controller.delegate = self
            controller.selectedYearIndex = self.selectedYearIndex
            controller.selectedMonthIndex = self.selectedMonthIndex
            controller.selectedSpeciesIndex = self.selectedSpeciesIndex
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView()
        
        if let fencedAnnotation = annotation as? OccurrenceAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: fencedAnnotation.identifier) {
                annotationView = dequeuedView
            } else {
                annotationView = MKAnnotationView(annotation: fencedAnnotation, reuseIdentifier: fencedAnnotation.identifier)
            }
            
            annotationView.image = UIImage(named: fencedAnnotation.identifier.lowercased())
            annotationView.canShowCallout = true
//            annoationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
            return annotationView
        } else if let myLocationAnnotation = annotation as? PinAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: myLocationAnnotation.identifier) {
                annotationView = dequeuedView
            } else {
                annotationView = MKAnnotationView(annotation: myLocationAnnotation, reuseIdentifier: myLocationAnnotation.identifier)
            }
            
            annotationView.image = UIImage(named: "pin")
            annotationView.canShowCallout = true
        }
        
        
        return annotationView
    }

}
