//
//  AuthViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 19/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseMLVision


//import TesseractOCR

class AuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.gray)

    var user = [String:Any]()
    var notificationDetails = [String: Any]()
    
    var authenticatedUser : User!
    //var textRecognizer: VisionTextRecognizer!
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!
    var toggle : Bool = false
    
    var tag = 0
    var size : CGFloat = 0.0
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true
        self.hideKeyboard()
        
        username.delegate = self
        password.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(AuthViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AuthViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //self.view.addSubview(activityIndicator)

        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings

        db = Firestore.firestore()
        
        let loggedIn = defaults.bool(forKey:"loggedIn")
        if loggedIn {
            indicator.isHidden = false
            indicator.center = self.view.center
            indicator.startAnimating()
            indicator.hidesWhenStopped = true
            if FirestoreDAO.authenticatedUser != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                FirestoreDAO.getUserDataForBackgroundTask(from: defaults.string(forKey: "userId")!, complete: {(user) in
                    
                    let remindersForPrograms = self.defaults.bool(forKey:"scheduledProgramReminder")
                    if !remindersForPrograms {
                        var programsList = [Program]()
                        let programs = FirestoreDAO.authenticatedUser.programs
                        if !programs.isEmpty {
                            for program in programs as NSDictionary {
                                let p = program.value as! Program
                                let days = Calendar.current.dateComponents([.day], from: Date(), to: p.startDate as Date).day
                                if days! >= 1 {
                                    programsList.append(p)
                                }
                            }
                            print(programsList.count)
                        }
                        Reminder.scheduledProgramReminder(for: programsList)
                    }
                    
                    let remindersForAnimals = self.defaults.bool(forKey:"setRemindersForAnimals")
                    if !remindersForAnimals {
                        Reminder.setOrUpdateRemindersForAnimals(notifications: FirestoreDAO.notificationDetails)
                    }
                    
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                })
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    

//    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
//        return false // return true if you need to interrupt tesseract before it finishes
//    }
    
    func getUserInfoForBackgroundTask(with userId : String){
        FirestoreDAO.getUserDataForBackgroundTask(from: userId, complete: {(user) in
            
            //self.calculateTotalNotifications(of: user)
            //print(self.overDueBaitsForProgram)
        })
    }
    
    func getUserInfoForBackgroundTaskWith(with userId : String, complete: @escaping (User) -> Void){
        FirestoreDAO.getUserDataForBackgroundTask(from: userId, complete: {(user) in
            complete(user!)
            //self.calculateTotalNotifications(of: user)
            //print(self.overDueBaitsForProgram)
        })
    }

    @IBAction func showHidePassword(_ sender: Any) {
        password.isSecureTextEntry = !toggle
        toggle = !toggle
    }
    
//    @IBAction func register(_ sender: Any) {
//        guard let password = password.text else {
//            displayErrorMessage("Please Enter a password")
//            return
//        }
//
//        guard let username = username.text else {
//            displayErrorMessage("Please Enter a password")
//            return
//        }
//
//        Auth.auth().createUser(withEmail: username, password: password){(user, error) in
//            if error != nil{
//                self.displayErrorMessage(error!.localizedDescription)
//            }
//        }
//
//    }

    @IBAction func logIn(_ sender: UIButton) {
        guard let password = password.text, password != "" else {
            displayErrorMessage("Please Enter a password")
            return
        }

        guard let username = username.text, username != "" else {
            displayErrorMessage("Please Enter a username")
            return
        }
        //self.startAnimating()
        self.view.endEditing(true)
        indicator.isHidden = false
        indicator.startAnimating()
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        //view.insertSubview(activityIndicator, aboveSubview: view.subviews[0])
        //        view.bringSubview(toFront: activityIndicator)
        //view.addSubview(activityIndicator)
        print(view.subviews)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        FirestoreDAO.authenticateUser(with: username, password: password, complete: {(result) in
            if "Invalid username" == result {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayErrorMessage("Please enter correct username")
            } else if result == "Invalid password"{
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayErrorMessage("Please enter correct password")
            } else if result == "Fetch Notification" {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayErrorMessage("Error in fetching user details")
            } else {
                self.defaults.set(true, forKey: "loggedIn")
                self.defaults.set(FirestoreDAO.authenticatedUser.id, forKey: "userId")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
        
//        let usersRef = db.collection("users")
//        var query = usersRef.whereField("username", isEqualTo: username)
//
//        query.getDocuments(completion: {(document, error) in
//            if (document?.documents.isEmpty ?? nil)! {
//                self.indicator.stopAnimating()
//                self.indicator.isHidden = true
//                UIApplication.shared.endIgnoringInteractionEvents()
//                self.displayErrorMessage("Please enter correct username")
//            } else {
//                if document?.documents[0].data()["password"] as! String != password {
//                    self.indicator.stopAnimating()
//                    self.indicator.isHidden = true
//                    UIApplication.shared.endIgnoringInteractionEvents()
//                    self.displayErrorMessage("Please enter correct password")
//                } else {
//                    self.user = (document?.documents[0].data())!
//                    self.user["id"] = (document?.documents[0].documentID)!
//
//                    self.authenticatedUser = User(
//                        id : self.user["id"] as! String,
//                        licensePath: self.user["licensePath"] as? String,
//                        licenseExpiryDate: Util.convertStringToDate(string: (self.user["licenseExpiryDate"] as! String)),
//                        username: self.user["username"] as! String,
//                        password: self.user["password"] as! String,
//                        program: self.user["programs"] as? Program
//                    )
//
//                    print(self.authenticatedUser)
//
//                    self.defaults.set(document?.documents[0].documentID, forKey: "userId")
//                    self.defaults.set(true, forKey: "loggedIn")
//                    let notificationsRef = self.db.collection("notifications")
//                    query = notificationsRef.whereField("notificationOfUser", isEqualTo: document?.documents[0].documentID)
//
//                    query.getDocuments(completion: {(result, error) in
//                        if ((result?.documents.isEmpty)!) {
//                            self.indicator.stopAnimating()
//                            self.indicator.isHidden = true
//                            UIApplication.shared.endIgnoringInteractionEvents()
//                            self.displayErrorMessage("Error in fetching user details")
//                        } else {
//                            self.notificationDetails = (result?.documents[0].data())!
//                            self.notificationDetails["id"] = (result?.documents[0].documentID)!
//                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
//                        }
//                    })
//                }
//            }
//        })

    }

    func displayErrorMessage(_ errorMessage: String){
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            let tabBarController = segue.destination as! TabBarViewController
            let count = tabBarController.viewControllers?.count
            let settingsVC = tabBarController.viewControllers![count!-1] as! MoreTableViewController
            //settingsVC.user = authenticatedUser
            settingsVC.notificationDetails = notificationDetails
            //self.endAnimating()
            indicator.stopAnimating()
            indicator.isHidden = true
            UIApplication.shared.endIgnoringInteractionEvents()
            FirestoreDAO.user = user
            
        }
    }


}

extension AuthViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(AuthViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }

    func addActivityIndicator() {

    }

    func startAnimating() {
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        //view.insertSubview(activityIndicator, aboveSubview: view.subviews[0])
//        view.bringSubview(toFront: activityIndicator)
        //view.addSubview(activityIndicator)
        print(view.subviews)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }

    func endAnimating() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        tag = textField.tag
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tag = textField.tag
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                if tag == 0 {
                    size = keyboardSize.height
                    self.view.frame.origin.y -= 150
                    print(keyboardSize)
                } else {
                    size = size - keyboardSize.height
                    size = size + keyboardSize.height
                    print(keyboardSize)
                    self.view.frame.origin.y -= 150
                }
                
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
