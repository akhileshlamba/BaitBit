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

class AuthViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    var user = [String:Any]()
    //var textRecognizer: VisionTextRecognizer!
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboard()

        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()

//        let vision = Vision.vision()
//        textRecognizer = vision.onDeviceTextRecognizer()


//        let visionImage = VisionImage(image: UIImage(named: "test2.jpg")!)
//        textRecognizer.process(visionImage) { result, error in
//
//            guard error == nil, let result = result else {
//                return
//            }
//            let substrings = result.text.split(separator: "\n")
//            if !substrings.contains("Agricultural Chemical User Permit") {
//                print("Inside")
//            }
//
//            print(result.text)
//        }

        // Do any additional setup after loading the view.
    }

//    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
//        return false // return true if you need to interrupt tesseract before it finishes
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
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

        Auth.auth().createUser(withEmail: username, password: password){(user, error) in
            if error != nil{
                self.displayErrorMessage(error!.localizedDescription)
            }
        }

    }

    @IBAction func logIn(_ sender: Any) {
        guard let password = password.text else {
            displayErrorMessage("Please Enter a password")
            return
        }

        guard let username = username.text else {
            displayErrorMessage("Please Enter a password")
            return
        }

        let usersRef = db.collection("users")
        let query = usersRef.whereField("username", isEqualTo: username)

        query.getDocuments(completion: {(document, error) in
            if (document?.documents.isEmpty ?? nil)! {
                self.displayErrorMessage("Please enter correct username")
            } else {
                if document?.documents[0].data()["password"] as! String != password {
                    self.displayErrorMessage("Please enter correct username")
                } else {
                    self.user = (document?.documents[0].data())!
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        })

//        Auth.auth().signIn(withEmail: username, password: password){(user, error) in
//            if error != nil{
//                self.displayErrorMessage(error!.localizedDescription)
//            }
//        }



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
            let settingsVC = tabBarController.viewControllers![count!-1] as! SettingsTableViewController
            settingsVC.user = user
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

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
