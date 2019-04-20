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
    @IBOutlet weak var image: UIImageView!
    let formatter = DateFormatter()
    var db: Firestore!
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "MMM dd, yyyy"
        showDatePicker()
        
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
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
        
        
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": username,
            "password": password,
            "licenseExpiryDate": licenseExpiryDate
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
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
