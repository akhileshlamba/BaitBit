//
//  BaitsViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class BaitsViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var bait_laid_date: UITextField!
    @IBOutlet weak var location: UITextField!
    var program: Bait_program!
    let formatter = DateFormatter()
    
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    let datePicker = UIDatePicker()
    
    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        formatter.dateFormat = "dd/MM/yyyy"
        
        bait_laid_date.text = formatter.string(from: Date())
        
        super.viewDidLoad()
        showDatePicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }

    func showDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        bait_laid_date.inputAccessoryView = toolbar
        bait_laid_date.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        if bait_laid_date.isFirstResponder {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            bait_laid_date.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    @IBAction func get_Location(_ sender: Any) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addBait(_ sender: Any) {
        
        if (bait_laid_date.text?.isEmpty)! || (location.text?.isEmpty)! {
            displayMessage("You have not entered value in any one field. Please Try again", "Save Failed")
        } else {
            
            let baits_info = NSEntityDescription.insertNewObject(forEntityName: "Baits_Info", into: context) as! Baits_Info
            baits_info.laid_date = NSDate()
            
            if(!(location.text?.contains(","))!){
                displayMessage("You have not entered the correct coordinates format. They are of the form 12.23, 42.123", "Coordinates Error")
            } else{
                let latlong = location.text?.components(separatedBy: ",")
                baits_info.latitude = Double(latlong![0]) as! Double
                baits_info.longitude = Double(latlong![1]) as! Double
                baits_info.status = true
                program.addToBaits(baits_info)
                baits_info.program = program
            }
            
            do {
                try context.save()
                let controller = self.navigationController?.viewControllers[1]
                print(NSStringFromClass((controller?.classForCoder)!))
                print(controller?.isKind(of: BaitProgramTableViewController.self))
                if controller is BaitProgramTableViewController {
                    self.navigationController?.popToViewController(controller!, animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                //performSegue(withIdentifier: "addbait", sender: nil)
            } catch let error {
                print("Could not save to core data: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        currentLocation = loc.coordinate
        location.text = String(currentLocation.latitude) + "," + String(currentLocation.longitude)
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
