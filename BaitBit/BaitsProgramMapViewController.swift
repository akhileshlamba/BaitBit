//
//  BaitsProgramMapViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class BaitsProgramMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D(latitude: -37.87763, longitude: 145.045374)
    var locationManager: CLLocationManager = CLLocationManager()
    var program: Program?
    var baits: [Bait] = []
    var selectedBait: Bait?
    var filters: (startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool)?
    @IBOutlet weak var backToCurrentLocationButton: UIButton!
    
    var baitAnnotations: [BaitAnnotation] = []
    var filteredBaitAnnotations: [BaitAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let controller = navController.viewControllers[navController.viewControllers.count - 2]
            if (controller.isKind(of: TabBarViewController.self)) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = .clear
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Add bait"), style: .plain, target: self, action: #selector(self.addBait))
                self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(self.filter)))
            }
        }
        
        
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


    }
    
    @objc func addBait() {
        performSegue(withIdentifier: "AddBaitSegue", sender: nil)
    }
    
    @objc func filter() {
        performSegue(withIdentifier: "BaitFilterSegue", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.program = Program.program
        loadData()
    }
    
    @IBAction func backToCurrentLocation(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        sender.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.stopUpdatingLocation()
        self.backToCurrentLocationButton.isHidden = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let annotations = mapView.annotations
        for annotation in annotations {
            if annotation is PinAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
    

    func loadData() {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        self.baitAnnotations.removeAll()
        if !self.baits.isEmpty {
            for bait in self.baits {
                if bait.latitude != 0 || bait.longitude != 0 || bait.program != nil {
                    let baitAnnotation = BaitAnnotation(bait: bait)
                    self.baitAnnotations.append(baitAnnotation)
                }
            }
        } else if self.program != nil {
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
        }
        applyFilters()
        
    }
    
    func applyFilters() {
        self.filteredBaitAnnotations = self.baitAnnotations
        guard self.filters != nil else {
            self.mapView.addAnnotations(filteredBaitAnnotations)
            return
        }
        
        // startDate <= laidDate
        if let startDate = filters?.startDate {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return Calendar.current.dateComponents([.day], from: startDate, to: annotation.bait.laidDate as Date).day! >= 0
            })
        }
        
        // laidDate <= endDate
        if let endDate = filters?.endDate {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return Calendar.current.dateComponents([.day], from: endDate, to: annotation.bait.laidDate as Date).day! <= 0
            })
        }
        
        if !filters!.showOverdue {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !annotation.bait.isOverdue
            })
        }
        
        if !filters!.showDueSoon {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !annotation.bait.isDueSoon
            })
        }
        
        if !filters!.showActive {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !annotation.bait.isActive
            })
        }
        
        if !filters!.showTaken && !filters!.showUntouched {
            filteredBaitAnnotations = filteredBaitAnnotations.filter({ (annotation) -> Bool in
                return !annotation.bait.isRemoved
            })
        }
        
        self.mapView.addAnnotations(filteredBaitAnnotations)

    }
    
    // This method is to keep track of the user's current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        self.mapView.setCenter(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), animated: true)
        
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
            let calloutButton = UIButton(type: .infoLight)
            calloutButton.addTarget(self, action: #selector(self.didSelectBait), for: .touchUpInside)
            annoationView.rightCalloutAccessoryView = calloutButton
            
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
    
    @objc func didSelectBait() {
        performSegue(withIdentifier: "BaitDetailSegue", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? BaitAnnotation {
            self.selectedBait = annotation.bait
//            performSegue(withIdentifier: "BaitDetailSegue", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddBaitSegue" {
            let controller = segue.destination as! AddBaitViewController
            controller.program = self.program
        }
        
        if segue.identifier == "BaitDetailSegue" {
            let controller = segue.destination as! BaitDetailsViewController
            controller.bait = self.selectedBait
        }
        
        if segue.identifier == "BaitFilterSegue" {
            let controller = segue.destination as! BaitFilterTableViewController
            // TODO:
            controller.filters = self.filters
            controller.delegate = self
        }
    }
}

extension BaitsProgramMapViewController: BaitFilterUpdateDelegate {
    func updateData(filters: (startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool)) {
        // TODO: 
        self.filters = filters
    }
}
