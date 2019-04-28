//
//  BaitDetailsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class BaitDetailsViewController: UIViewController {
    
    var bait: Bait!
    @IBOutlet weak var dueTextField: UILabel!
    @IBOutlet weak var durationTextField: UILabel!
    @IBOutlet weak var startDateTextField: UILabel!
    @IBOutlet weak var baitImageView: UIImageView!
    @IBOutlet weak var baitDetailsTitleView: UIView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var baitImageContainerView: UIView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFields()
        self.loadBaitImage()

        // Do any additional setup after loading the view.
    }
    
    func setFields() {
        self.dueTextField.text = "Due in \(self.bait.numberOfDaysBeforeDue) day(s)"
        self.durationTextField.text = "\(self.bait.durationInDays) days(s)"
        self.startDateTextField.text = "\(Util.setDateAsString(date: self.bait.laidDate))"
    }

    @IBAction func dragDownFromTop(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.edges == .top {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadBaitImage() {
        FirestoreDAO.fetchImage(for: self.bait) { (image) in
            self.baitImageView.image = image
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "RemoveBaitSegue" {
            let controller = segue.destination as! RemoveBaitTableViewController
            controller.bait = self.bait
        }
    }
    

}
