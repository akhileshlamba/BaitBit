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
    func updateData(yearIndex: Int, monthIndex: Int, species: String)
}

enum Species: String, CaseIterable {
    case foxes = "vulpes"
    case rabbits
    case dogs
    case pigs
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, FilterUpdateDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    let databaseRef: DatabaseReference = Database.database().reference().child("invasive_species")
    var occurrenceAnnotations: [OccurrenceAnnotation] = []
    var selectedYearIndex: Int = 0
    var selectedMonthIndex: Int = 0
    var selectedSpecies: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        loadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // This method is to load data from remote dataset
    func updateData(yearIndex: Int, monthIndex: Int, species: String) {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: Date())
        for annotation in occurrenceAnnotations {
            if annotation.isWithin(year: Int(currentYear)! - yearIndex) && annotation.isWithin(month: monthIndex) && annotation.isWithin(species: species) {
                self.mapView.addAnnotation(annotation)
            }
        }
        
        self.selectedYearIndex = yearIndex
        self.selectedMonthIndex = monthIndex
        self.selectedSpecies = species
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
                
                self.updateData(yearIndex: 0, monthIndex: 0, species: "")
            }
        }
    }
    
    // This method is to keep track of the user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 100000, 100000)
        self.mapView.setRegion(viewRegion, animated: true)
        
        let annotation = PinAnnotation(coordinate: currentLocation, identifier: "currentLocation")
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
            controller.selectedSpecies = self.selectedSpecies
        }
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
//            annoationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
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

}



//extension MapViewController: UITextViewDelegate {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//
//    }
//}
