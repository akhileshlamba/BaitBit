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

    @IBOutlet weak var add_bait_button: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    var program: Bait_program?
    var baits: [Baits_Info] = []
    
    var baitAnnotations: [BaitAnnotation] = []
    private var context : NSManagedObjectContext
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let controller = navController.viewControllers[navController.viewControllers.count - 2]
            if (controller.isKind(of: HomeViewController.self)) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = .clear
            }
        }
        
        //let controller = self.navigationController?.topViewController
        
        
        loadData()
        print(self.baits.count)
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
//        do{
//            programList = try context.fetch(fetchRequest) as! [Bait_program]
//            print("asdasdsduhqd qwod hqw")
//            print(programList.count)
//        } catch  {
//            fatalError("Failed to fetch animal list")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    

    func loadData() {
        for annotation in self.mapView.annotations {
            if !(annotation is PinAnnotation) {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        if self.program != nil {
            //        self.baitAnnotations.removeAll()
            if let baitList = self.program!.baits {
                for element in baitList {
                    if let bait = element as? Baits_Info {
                        if bait.latitude != 0 || bait.longitude != 0 || bait.program != nil{
                            let baitAnnotation = BaitAnnotation(bait_info: bait)
                            baitAnnotations.append(baitAnnotation)
                        }
                    }
                }
                self.mapView.addAnnotations(baitAnnotations)
            }
        }
        
        if !self.baits.isEmpty {
            for bait in self.baits {
                if bait.latitude != 0 || bait.longitude != 0 || bait.program != nil{
                    let baitAnnotation = BaitAnnotation(bait_info: bait)
                    baitAnnotations.append(baitAnnotation)
                }
            }
            self.mapView.addAnnotations(baitAnnotations)
        }
        
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
        let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:currentLocation.latitude, longitude:currentLocation.longitude), 4000, 4000)
        self.mapView.setRegion(viewRegion, animated: false)
        
        let annotation = PinAnnotation(coordinate: currentLocation, identifier: "currentLocation")
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
            
            annoationView.image = UIImage(named: fencedAnnotation.bait_info.program!.name!)
            annoationView.canShowCallout = true
            //annoationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
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
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddBaitSegue" {
            let controller = segue.destination as! BaitsViewController
            controller.program = self.program
        }
    }
    

}
