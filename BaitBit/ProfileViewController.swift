//
//  ProfileViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLVision

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var licenseImage: UIImageView!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var dateView: UIView!
    
    let formatter = DateFormatter()
    var actionSheet: UIAlertController?
    var textRecognizer: VisionTextRecognizer!
    var storage: Storage!
    var storageRef: StorageReference!
    let datePicker = UIDatePicker()
    
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var licenseButton: UIButton!
    var changeImage = Bool(false)
    var addLicense : Bool! = false
    
    var user: User!
    var user1 = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = FirestoreDAO.authenticatedUser
        if user.licenseExpiryDate == nil {
            licenseButton.setTitle("Upload your License", for: .normal)
            addLicense = true
        }
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        storage = Storage.storage()
        storageRef = storage.reference()
        
        formatter.dateFormat = "MMM dd, yyyy"
        showDatePicker()
        
        if !addLicense {
            licenseButton.setTitle("", for: .normal)
            updateButton.isHidden = true
            nameLabel.isHidden = true
            dateView.isHidden = true
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(upload))
            
            activityIndicator.center = self.view.center
            view.addSubview(activityIndicator)
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            self.storage.reference(forURL: user.licensePath as! String).getData(maxSize: 5 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.nameLabel.isHidden = false
                    self.nameLabel.text = "Hi, \(self.user.username )! "
                    self.updateButton.isHidden = false
                    self.dateView.isHidden = false
                    self.updateButton.setTitle("Add License", for: .normal)
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                } else{
                    let imageData = UIImage(data: data!)!
                    self.licenseImage.image = imageData
                    self.nameLabel.isHidden = false
                    self.dateView.isHidden = false
                    self.nameLabel.text = "Hi, \(self.user.username )! "
                    self.date.text = Util.setDateAsString(date: (self.user.licenseExpiryDate!))
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            })
        } else {
            nameLabel.isHidden = false
            self.nameLabel.text = "Hi, \(self.user.username )! "
            updateButton.isHidden = false
            self.dateView.isHidden = false
            updateButton.setTitle("Add License", for: .normal)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.user = FirestoreDAO.authenticatedUser!
    }
    
    @IBAction func updateLicense(_ sender: Any) {
        if licenseImage.image == nil {
            displayErrorMessage("Please choose or take image of License.", "Error")
            return
        }
        
        if date.text!.isEmpty {
            displayErrorMessage("Please set expiry date", "Error")
            return
        }
        
        if !date.text!.isEmpty {
            
            if Calendar.current.dateComponents([.day], from: Util.convertStringToDate(string: date.text!)! as Date, to: Date()).day! >= 0  {
                displayErrorMessage("Expiry date for license should be the future date", "Error")
                return
            }
        }
        
        savePhoto(licenseImage.image)
    }
    
    @objc func upload() {
        setUpCameraOptions()
    }
    
    func setUpCameraOptions() {
        self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add a Take Photo option
        self.actionSheet!.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            self.takePicture()
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
    
    @IBAction func chooseCamera(_ sender: Any) {
        
        setUpCameraOptions()
        licenseButton.setTitle("", for: .normal)
        
    }
    
    func displayErrorMessage(_ errorMessage: String, _ title: String){
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
        
        date.inputAccessoryView = toolbar
        date.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        if date.isFirstResponder {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            date.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePicture() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            self.displayErrorMessage("Camera unvailable", "Error")
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
            self.licenseImage.image = pickedImage
            self.changeImage = true
            self.updateButton.isHidden = false
            
            
            let vision = Vision.vision()
            textRecognizer = vision.onDeviceTextRecognizer()
            
            let visionImage = VisionImage(image: pickedImage)
            textRecognizer.process(visionImage) { result, error in
                
                guard error == nil, let result = result else {
                    self.displayErrorMessage("Problem in recognising the image", "Error")
                    return
                }
                
                let range = NSRange(location: 0, length: result.text.utf16.count)
                let regex = try! NSRegularExpression(pattern: "[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}")
                
                let matches = regex.firstMatch(in: result.text, options: [], range: range)
                
                let substrings = result.text.split(separator: "\n")
                if !substrings.contains("Agricultural Chemical User Permit") {
                    self.displayErrorMessage("Invalid License", "Error")
                    return
                } else {
                    let date = Util.convertStringToDate(string: matches.map {String(result.text[Range($0.range, in: result.text)!])}!)
                    self.date.text = Util.setDateAsString(date: date!)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        updateButton.isHidden = false
        displayErrorMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePhoto(_ pickedImage: UIImage?) {
        
        guard let image = pickedImage else {
            displayErrorMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        let licenseDate = date.text!
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        FirestoreDAO.updateLicenseImageAndData(of: user, image: image, licenseDate: licenseDate, complete: {(result) in
            if result {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.displayErrorMessage("License updated Successfully!", "Sucess")
            } else {
                self.displayErrorMessage("Problem in updating License", "Error")
            }
        })
    }
    
}
