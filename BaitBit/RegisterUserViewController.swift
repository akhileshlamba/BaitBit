//
//  RegisterUserViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 20/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var licenseExpiryDate: UITextField!
    @IBOutlet weak var licenseImage: UIImageView!
    let formatter = DateFormatter()
    var db: Firestore!
    let datePicker = UIDatePicker()
    
    var actionSheet: UIAlertController?
    
    var storage: Storage!
    var storageRef: StorageReference!
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storage = Storage.storage()
        storageRef = storage.reference()
        
        formatter.dateFormat = "MMM dd, yyyy"
        showDatePicker()
        
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
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
        
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let password = password.text else {
            displayErrorMessage("Please Enter a password")
            return
        }
        
        guard let username = username.text else {
            displayErrorMessage("Please Enter a password")
            return
        }
        
        guard let licenseExpiryDate = licenseExpiryDate.text else {
            displayErrorMessage("Please Enter a password")
            return
        }
        
        guard let image = licenseImage.image else {
            displayErrorMessage("Please select or take image of License")
            return
        }
        
        
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": username,
            "password": password,
            "licenseExpiryDate": licenseExpiryDate
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.userId = ref!.documentID
                print("Document added with ID: \(ref!.documentID)")
                self.savePhoto(image)
                
            }
        }
        
    }
    
    func displayErrorMessage(_ errorMessage: String){
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
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
    
    func takePicture() {
        let controller = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            self.displayErrorMessage("Camera unvailable")
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayErrorMessage("There was an error in getting the photo")
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePhoto(_ pickedImage: UIImage?) -> String? {
        guard let image = pickedImage else {
            displayErrorMessage("Cannot save until a photo has been taken!")
            return nil
        }
       
        // Preparing timestamp and image data
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.1)!
        
        
        let imageRef = storageRef.child("\(userId)/License/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (metaData, error) in
            if error != nil {
            } else {
                self.displayErrorMessage("Could not upload image")
                
                imageRef.downloadURL(completion: {(url, error) in
                    if let error = error{
                        self.displayErrorMessage(error.localizedDescription)
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
                            self.displayErrorMessage("Image saved to Firebase")
                        }
                    }
                })
            }
        }
        
        return nil
    }
    
}
