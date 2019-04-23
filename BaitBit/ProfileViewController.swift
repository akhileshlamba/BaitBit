//
//  ProfileViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var date: UILabel!
    
    var storage = Storage.storage()
    
    var user = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Hi, \(user["username"] as! String)! "
        date.text = "Expiry Date     \(user["licenseExpiryDate"] as! String)"
        
        self.storage.reference(forURL: user["licensePath"] as! String).getData(maxSize: 5 * 1024 * 1024, completion: { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else{
                let imageData = UIImage(data: data!)!
                self.image.image = imageData
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateLicense(_ sender: Any) {
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
