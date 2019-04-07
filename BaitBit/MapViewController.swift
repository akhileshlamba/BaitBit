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
    var filteredOccurrenceAnnotations: [OccurrenceAnnotation] = []
    
    var speciesPicker = UIPickerView()
    var yearPicker = UIPickerView()
    let speciesDataSource: [String] = ["All species", "vulpes", "rabbits"]
    var yearDataSource: [Int]?
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        speciesTextField.inputView = speciesPicker
        yearPicker.dataSource = self
        yearPicker.delegate = self
        yearTextField.inputView = yearPicker
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: Date()))!
        
        yearDataSource = Array(1950...year)
        yearDataSource?.reverse()

        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addMyAnnotation() {
        
    }
    
    // This method is to load data from remote dataset
    func updateData(species: String) {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
//        self.mapView.removeAnnotations(self.mapView.annotations)
        
        
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
            self.mapView.addAnnotations(self.occurrenceAnnotations)
        }
    }
    
    func loadData() {
//        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        self.occurrenceAnnotations.removeAll()
        for species in speciesDataSource {
            self.databaseRef.child(species).observeSingleEvent(of: .value) { (snapshot) in
                guard let dataset = snapshot.value as? NSArray else {
                    return
                }
                
                for record in dataset {
                    let record = record as! NSDictionary
                    let lat = record["Latitude"] as! Double
                    let long = record["Longitude"] as! Double
                    let month = record["Month"] as! Int
                    let year = record["Year"] as! Int
                    let occurrence = OccurrenceAnnotation(title: species, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), subtitle: "\(year) - \(month)")
                    self.occurrenceAnnotations.append(occurrence)
                }
                self.mapView.addAnnotations(self.occurrenceAnnotations)
            }
        }
        
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

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if speciesTextField.isFirstResponder {
            return speciesDataSource.count
        } else {
            return yearDataSource!.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if speciesTextField.isFirstResponder {
            speciesTextField.text = speciesDataSource[row]
        } else {
            yearTextField.text = "\(yearDataSource![row])"
        }
        
//        if row == 0 {
//            loadData()
//        } else {
//            loadData(species: speciesDataSource[row])
//        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if speciesTextField.isFirstResponder {
            return speciesDataSource[row]
        } else {
            return "\(yearDataSource![row])"
        }
    }
}

//extension MapViewController: UITextViewDelegate {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//
//    }
//}
