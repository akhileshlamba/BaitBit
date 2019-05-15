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
    
    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D(latitude: -37.87763, longitude: 145.045374)
    var locationManager: CLLocationManager = CLLocationManager()
    var program: Program?
    var baits: [Bait] = []
    var selectedBait: Bait?
    var filters: (isTaken: Bool, isRemovedOverdue: Bool, target: Bool, nontarget: Bool)?
    @IBOutlet weak var backToCurrentLocationButton: UIButton!

    var baitAnnotations: [BaitAnnotation] = []
    var filteredBaitAnnotations: [BaitAnnotation] = []
    
    var isTrackingCurrentLoc: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(self.filter))
        
        
        loadData()
        print(self.baits.count)
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        var focus: CLLocationCoordinate2D?
        if self.baitAnnotations.count > 0 {
            focus = baitAnnotations[0].coordinate
        } else {
            focus = currentLocation
        }
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: focus!.latitude, longitude: focus!.longitude), 4000, 4000), animated: false)
        
        // add a tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapping))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func filter() {
        performSegue(withIdentifier: "MapFilterSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @IBAction func backToCurrentLocation(_ sender: UIButton) {
        self.mapView.setCenter(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), animated: true)
        self.isTrackingCurrentLoc = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isTrackingCurrentLoc = false
    }
    
    @objc func tapping() {
        self.backToCurrentLocationButton.isHidden = !self.backToCurrentLocationButton.isHidden
    }

    func loadData() {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        self.baitAnnotations.removeAll()
        if self.program != nil {
            if let baitList = self.program?.baits.values {
                for element in baitList {
                    if let bait = element as? Bait {
                        if bait.latitude != 0 || bait.longitude != 0 || bait.program != nil {
                            let baitAnnotation = BaitAnnotation(bait: bait)
                            self.baitAnnotations.append(baitAnnotation)
                        }
                    }
                }
            }
        } else if !self.baits.isEmpty {
            for bait in self.baits {
                if bait.latitude != 0 || bait.longitude != 0 || bait.program != nil {
                    let baitAnnotation = BaitAnnotation(bait: bait)
                    self.baitAnnotations.append(baitAnnotation)
                }
            }
        }
        applyFilters()
        
    }
    
    func applyFilters() {
        self.filteredBaitAnnotations = self.baitAnnotations
        guard self.filters != nil else {
            self.mapView.addAnnotations(filteredBaitAnnotations)
            return
        }
        
        if !filters!.isTaken {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !(annotation.bait.isTaken ?? false)
            })
        }
        
        if !filters!.isRemovedOverdue {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !(annotation.bait.isRemovedOverdue ?? false)
            })
        }
        
        if !filters!.target {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !(annotation.bait.targetCarcassFound ?? false)
            })
        }
        
        if !filters!.nontarget {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return annotation.bait.targetCarcassFound ?? true
            })
        }
        
        self.mapView.addAnnotations(filteredBaitAnnotations)
        
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
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annoationView = MKAnnotationView()
        
        if let fencedAnnotation = annotation as? BaitAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: fencedAnnotation.identifier) {
                annoationView = dequeuedView
            } else {
                annoationView = MKAnnotationView(annotation: fencedAnnotation, reuseIdentifier: fencedAnnotation.identifier)
            }
            
            annoationView.image = UIImage(named: fencedAnnotation.imageName)
            annoationView.canShowCallout = true
            
            return annoationView
        } else if let myLocationAnnotation = annotation as? PinAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: myLocationAnnotation.identifier) {
                annoationView = dequeuedView
            } else {
                annoationView = MKAnnotationView(annotation: myLocationAnnotation, reuseIdentifier: myLocationAnnotation.identifier)
            }
            
            annoationView.image = UIImage(named: "pin")
            annoationView.canShowCallout = true
        }
        
        
        return annoationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? BaitAnnotation {
            self.selectedBait = annotation.bait
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapFilterSegue" {
            let controller = segue.destination as! CompletedProgramsMapFilterTableViewController
            controller.filters = self.filters
            controller.delegate = self
        }
    }
    
}

extension CompletedProgramsMapViewController: CompletedProgramsMapFilterUpdateDelegate {
    func updateData(filters: (isTaken: Bool, isRemovedOverdue: Bool, target: Bool, nontarget: Bool)) {
        self.filters = filters
    }
}
