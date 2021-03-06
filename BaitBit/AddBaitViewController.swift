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

//    @IBOutlet weak var bait_laid_date: UITextField!
//    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var baitPhoto: UIImageView!
    var actionSheet: UIAlertController?

    var program: Program!
    let formatter = DateFormatter()

    var currentLocation = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
//    let datePicker = UIDatePicker()
    @IBOutlet weak var addBaitTableView: UITableView!

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let dataSource = ["Date", "Latitude", "Longitude"]
    let imageDataSource = ["date", "latitude", "longitude"]
    var valueDataSource = ["", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        addBaitTableView.delegate = self
        addBaitTableView.dataSource = self

        formatter.dateFormat = "MMM dd, yyyy"
        self.valueDataSource[0] = formatter.string(from: Date())
        self.addBaitTableView.tableFooterView = UIView(frame: .zero)
        self.getLocation()


    }

    func getLocation() {
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
        let lat = self.valueDataSource[1]
        let long = self.valueDataSource[2]
        guard lat != "" && long != "" else {
            displayMessage("Cannot get your current location", "Save Failed")
            return
        }

        let timestamp = UInt(Date().timeIntervalSince1970)
        let bait = Bait(id: "\(timestamp)",
                        laidDate: NSDate(),
                        latitude: Double(lat) as! Double,
                        longitude: Double(long) as! Double,
                        photoPath: nil,
                        photoURL: nil,
                        program: self.program,
                        isRemoved: false)

        if let image = self.baitPhoto.image {
            bait.photoPath = self.savePhoto(image)
        }

        self.program.addToBaits(bait: bait)

        self.loading.startAnimating()
        FirestoreDAO.createOrUpdate(bait: bait, for: self.program, complete: {(result) in
            guard result else {
                self.loading.stopAnimating()
                self.displayMessage("Problem in updating bait", "Error", completion: {(_) in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }

            Program.program = self.program

            guard let image = self.baitPhoto.image else {
                self.loading.stopAnimating()
                self.displayMessage("Bait created successfully!", "Sucess", "OK", completion: {(_) in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }

            FirestoreDAO.updateImageAndData(for: bait, image: image, complete: {(result) in
                self.loading.stopAnimating()
                if result {
                    self.displayMessage("Bait created successfully!", "Sucess", "OK", completion: {(_) in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self.displayMessage("Bait created successfully, but failed to update bait image", "Partial Error", completion: {(_) in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        })
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        self.currentLocation = loc.coordinate
        self.valueDataSource[1] = String(currentLocation.latitude)
        self.valueDataSource[2] = String(currentLocation.longitude)
        self.addBaitTableView.reloadData()
    }

    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func displayMessage(_ message: String, _ title: String, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: completion))
        self.present(alertController, animated: true, completion:  nil)
    }

    func displayMessage(_ message: String, _ title: String, _ actionTitle: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func displayMessage(_ message: String, _ title: String, _ actionTitle: String, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style:
            UIAlertActionStyle.default, handler: completion))
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

        // Preparing timestamp and image data
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!

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

extension AddBaitViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddBaitCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        cell.detailTextLabel?.text = self.valueDataSource[indexPath.row]
        cell.imageView?.image = UIImage(named: self.imageDataSource[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
