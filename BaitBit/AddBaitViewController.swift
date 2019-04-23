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

class AddBaitViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var bait_laid_date: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var baitPhoto: UIImageView!
    var actionSheet: UIAlertController?

    var program: Bait_program!
    let formatter = DateFormatter()
    
    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    let datePicker = UIDatePicker()
    
    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        formatter.dateFormat = "MMM dd, yyyy"
        
        bait_laid_date.text = formatter.string(from: Date())
        
        super.viewDidLoad()
        showDatePicker()
        location.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    @objc func done() {
        let controller = self.navigationController?.viewControllers[2]

        if controller is AddProgramViewController {
            let programTableViewController = self.navigationController?.viewControllers[1]
            self.navigationController?.popToViewController(programTableViewController!, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }

    func showDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        bait_laid_date.isEnabled = false
        
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
                if (Double(latlong![0]) != nil) && (Double(latlong![1]) != nil) {
                    baits_info.latitude = Double(latlong![0]) as! Double
                    baits_info.longitude = Double(latlong![1]) as! Double
                    baits_info.status = true
                    if let image = self.baitPhoto.image {
                        baits_info.path = self.savePhoto(image)
                    }
                    
                    program.addToBaits(baits_info)
                    baits_info.program = program
                    
                    print("bait_info: ")
                    print(baits_info)
                    print("")
                    do {
                        try context.save()
                        
//                        // create a success message
//                        let alertController = UIAlertController(title: "Success", message: "Bait Successfully Added", preferredStyle: UIAlertController.Style.alert)
//
//                        // display it for 1 second
//                        self.present(alertController, animated: true, completion: {
//                            let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
//                                alertController.dismiss(animated: true, completion: nil)
//                            })
//                        })
                        
                        displayMessage("Baiting Recorded Successfully", "Success", "OK")
                        
                    } catch let error {
                        print("Could not save to core data: \(error)")
                    }
                    
                } else {
                    displayMessage("Coordinates should be in numbers", "Coordinates Error")
                }
                
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
    
    func displayMessage(_ message: String, _ title: String, _ actionTitle: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style:
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
    
    @IBAction func displayPhotoOptions(_ sender: Any) {
        // create an actionSheet
        self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add a Take Photo option
        self.actionSheet!.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            self.takePhoto()
        }))
        
        // add a Choose from Album option
        self.actionSheet!.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { (_) in
            self.chooseFromAlum()
        }))
        
        // add a Cancel option
        self.actionSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // display the actionSheet
        self.present(self.actionSheet!, animated: true, completion: nil)
    }
    

}

extension AddBaitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhoto() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            displayMessage("Camera unvailable", "Error")
            return
        }
        
        controller.sourceType = UIImagePickerController.SourceType.camera
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func chooseFromAlum() {
        let controller = UIImagePickerController()
        
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let actionSheet = self.actionSheet {
            actionSheet.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking photo.")
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("did get into the if statement")
//            self.savePhoto(pickedImage)
            self.baitPhoto.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePhoto(_ pickedImage: UIImage?) -> String? {
        guard let image = pickedImage else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return nil
        }
//        guard let userID = Auth.auth().currentUser?.uid else {
//            displayMessage("Cannot upload image until logged in", "Error")
//            return
//        }
        
//        self.busy.startAnimating()
        
        // Preparing timestamp and image data
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!
        
        // Save image data to firebase storage
//        let imageRef = storageRef.child("\(userID)/\(date)")
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpg"
//        imageRef.putData(data, metadata: metadata) { (metaData, error) in
//            if error != nil {
//                self.displayMessage("Could not upload image", "Error")
//            } else {
//                // get image downloadURL, and save it to firebase database
//                imageRef.downloadURL(completion: { (url, error) in
//                    // get image downloadURL in firebase storage
//                    guard let downloadURL = url?.absoluteString else {
//                        return
//                    }
//
//                    // save to firebase database
//                    self.databaseRef.child(userID).child("pet/photopath").setValue(downloadURL)
//                    self.databaseRef.child(userID).child("pet/filepath").setValue("\(date)")
//
//                    self.photoView.image = image
//                    self.busy.stopAnimating()
//
//                    // create a success message
//                    let alertController = UIAlertController(title: "Success", message: "Image saved to Firebase", preferredStyle: UIAlertController.Style.alert)
//
//                    // display it for 1 second
//                    self.present(alertController, animated: true, completion: {
//                        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
//                            alertController.dismiss(animated: true, completion: nil)
//                        })
//                    })
//                })
//            }
//        }
        
        // save the image to a local file
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            return "\(date)"
        }
        
        // update photo for previous page
//        self.photoDelegate.updatePhoto("\(date)")
        return nil
    }

}
