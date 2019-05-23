//
//  RegisterUserViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 20/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLVision

class RegisterUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var licenseExpiryDate: UITextField!
    @IBOutlet weak var licenseImage: UIImageView!
    let formatter = DateFormatter()
    var db: Firestore!
    let datePicker = UIDatePicker()
    
    var actionSheet: UIAlertController?
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var storage: Storage!
    var storageRef: StorageReference!
    var userId: String!
    
    @IBOutlet weak var chooseCamera: UIButton!
    var textRecognizer: VisionTextRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storage = Storage.storage()
        storageRef = storage.reference()
        
        self.hideKeyboard()
        
        indicator.isHidden = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        formatter.dateFormat = "MMM dd, yyyy"
        showDatePicker()
        
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        username.delegate = self
        password.delegate = self
        
        chooseCamera.setTitle("Upload your License", for: .normal)
        
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        
        let visionImage = VisionImage(image: UIImage(named: "test.jpg")!)
        textRecognizer.process(visionImage) { result, error in
            
            guard error == nil, let result = result else {
                return
            }
            
            let range = NSRange(location: 0, length: result.text.utf16.count)
            print(range)
            print(result.text)
            let regex = try! NSRegularExpression(pattern: "[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}")
            
            let date = regex.firstMatch(in: result.text, options: [], range: range)
            
            let substrings = result.text.split(separator: "\n")
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        // create an actionSheet
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
        
//        chooseCamera.setTitle("Upload your License", for: .normal)
        
    }
    
    @IBAction func register(_ sender: Any) {
        indicator.isHidden = false
        indicator.center = self.view.center
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        if (username.text!.isEmpty){
            indicator.isHidden = true
            indicator.center = self.view.center
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            displayErrorMessage("Please Enter a username", "Error")
            return
        }
        
        if (password.text!.isEmpty){
            indicator.isHidden = true
            indicator.center = self.view.center
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            displayErrorMessage("Please Enter a password", "Error")
            return
        }
        
        if (password.text!.count < 6){
            indicator.isHidden = true
            indicator.center = self.view.center
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            displayErrorMessage("Password should be of minimum of 6 characters", "Error")
            return
        }
        
        
//        guard let licenseExpiryDate = licenseExpiryDate.text else {
//            displayErrorMessage("Please Enter a password", "Error")
//            return
//        }
//
//        guard let image = licenseImage.image else {
//            displayErrorMessage("Please select or take image of License", "Error")
//            return
//        }
        let name = username.text
        let pwd = password.text
        let expiryDate = licenseExpiryDate.text
        let image = licenseImage.image
        
        if image == nil && !expiryDate!.isEmpty {
            indicator.isHidden = true
            indicator.center = self.view.center
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            displayErrorMessage("Please select or take image of License before selecting date", "Error")
            return
        }
        
        if image != nil && expiryDate!.isEmpty {
            indicator.isHidden = true
            indicator.center = self.view.center
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            displayErrorMessage("Please select expiry date for license", "Error")
            return
        }
        if !expiryDate!.isEmpty {
            
            if Calendar.current.dateComponents([.day, .month, .year], from: Util.convertStringToDate(string: expiryDate!) as! Date, to: Date()).day! >= 0  {
                indicator.isHidden = true
                indicator.center = self.view.center
                indicator.stopAnimating()
                indicator.hidesWhenStopped = true
                displayErrorMessage("Expiry date for license should be the future date", "Error")
                return
            }
        }
        
        
        let user = User(
            username: name!,
            password: pwd!
        )
        
        FirestoreDAO.registerUser(with: user, complete: {(string) in
            if string.keys.contains("Duplicate User") {
                self.indicator.isHidden = true
                self.indicator.center = self.view.center
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.displayErrorMessage("User exists with the same username", "Error")
            } else if string.keys.contains("Save Error") {
                self.indicator.isHidden = true
                self.indicator.center = self.view.center
                self.indicator.hidesWhenStopped = true
                self.displayErrorMessage("Error in registering user", "Error")
            } else if string.keys.contains("Error in saving notification details") {
                self.indicator.isHidden = true
                self.indicator.center = self.view.center
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.displayErrorMessage("Error in saving notification details", "Error")
            } else if string.keys.contains("Success") {
                let user = string["Success"]
                if image != nil {
                    let date = Util.convertStringToDate(string: expiryDate!)
                    FirestoreDAO.updateLicenseImageAndData(of: user!!, image: image!, licenseDate: Util.setDateAsString(date: date!), complete: {(success) in
                        if success {
                            self.indicator.isHidden = true
                            self.indicator.center = self.view.center
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            self.displayErrorMessage("You are registered with the Baitbit", "Success", completion: {(_) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            self.indicator.isHidden = true
                            self.indicator.center = self.view.center
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            self.displayErrorMessage("Error in storing License image", "Error")
                        }
                    })
                } else {
                    self.indicator.isHidden = true
                    self.indicator.center = self.view.center
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    self.displayErrorMessage("You are registered with the Baitbit", "Success", completion: {(_) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                
            }
        })
        
//        let usersRef = db.collection("users")
//        let query = usersRef.whereField("username", isEqualTo: username)
//
//        query.getDocuments(completion: {(document, error) in
//            if (document?.documents.isEmpty ?? nil)! {
//                var ref: DocumentReference!
//                ref = self.db.collection("users").addDocument(data: [
//                    "username": username,
//                    "password": password,
//                    "licenseExpiryDate": licenseExpiryDate
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    } else {
//                        self.userId = ref.documentID
//                        print("Document added with ID: \(ref!.documentID)")
//                        self.db.collection("notifications").addDocument(data: [
//                            "overDue" : false,
//                            "dueSoon" : false,
//                            "documentation" : false,
//                            "notificationOfUser" : ref!.documentID
//                        ]) { err in
//                            if let err = err {
//                                print("Error adding document: \(err)")
//                            } else {
//                                let success = self.savePhoto(image)
//                                if success ?? false {
//                                    self.navigationController?.popViewController(animated: true)
//                                }
//                            }
//                        }
//                    }
//                }
//            } else {
//                self.displayErrorMessage("User exists with the same username", "Error")
//            }
//        })
        
    }
    
    func displayErrorMessage(_ errorMessage: String, _ title: String){
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(_ errorMessage: String, _ title: String, completion: ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donedatePicker))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDatePicker))
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        licenseExpiryDate.inputAccessoryView = toolbar
        licenseExpiryDate.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        if licenseExpiryDate.isFirstResponder {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            licenseExpiryDate.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    

}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
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
            self.chooseCamera.setTitle("", for: .normal)
            
//            DocumentVerification.checkLicense(pickedImage: pickedImage, complete: {(result) in
//                if result.keys.contains("Problem in recognising the image") {
//                    self.displayErrorMessage("Problem in recognising the image", "Error")
//                } else if result.keys.contains("Invalid License") {
//                    self.displayErrorMessage("Invalid License", "Error")
//                }else if result.keys.contains("Success") {
//                    let date = result["Success"]
//                    self.licenseExpiryDate.text = Util.setDateAsString(date: date as! NSDate)
//                }
//            })
            
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
                    self.licenseExpiryDate.text = Util.setDateAsString(date: date!)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayErrorMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePhoto(_ pickedImage: UIImage?) -> Bool? {
        guard let image = pickedImage else {
            displayErrorMessage("Cannot save until a photo has been taken!", "Error")
            return false
        }
       
        // Preparing timestamp and image data
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!
        
        if userId == nil {
            displayErrorMessage("User not saved", "Error")
            return false
        }
        let imageRef = storageRef.child("\(userId ?? "")/License/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
                self.displayErrorMessage("Error in saving image", "Error")
            } else {
                imageRef.downloadURL(completion: {(url, error) in
                    if let error = error{
                        self.displayErrorMessage(error.localizedDescription, "Error")
                        return
                    }else{
                        if let imageURL = url?.absoluteString{
                            let userRef = self.db.collection("users").document(self.userId)
                            userRef.updateData([
                                "licensePath": imageURL
                            ]) {
                                err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                            self.displayErrorMessage("You are registered with Baitbit", "Save")
                        }
                    }
                })
            }
        }
        
        return true
    }
    
}

extension RegisterUserViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(RegisterUserViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
