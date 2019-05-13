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
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var baitImageView: UIImageView!
    @IBOutlet weak var baitDetailsTitleView: UIView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var baitImageContainerView: UIView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFields()
        self.loadBaitImage()

        // Do any additional setup after loading the view.
    }
    
    func setFields() {
        if self.bait.numberOfDaysBeforeDue > 1 {
            self.dueLabel.text = "Due in \(self.bait.numberOfDaysBeforeDue) days"
        } else if self.bait.numberOfDaysBeforeDue == 1 {
            self.dueLabel.text = "Due tomorrow"
        } else if self.bait.numberOfDaysBeforeDue == 0 {
            self.dueLabel.text = "Due today"
        } else {
            self.dueLabel.text = "\(-self.bait.numberOfDaysBeforeDue) day(s) overdue"
        }
        if self.bait.isRemoved {
            self.dueLabel.text = "This bait was removed."
            self.removeButton.isHidden = true
        }
        self.durationLabel.text = self.bait.durationFormatted
        self.startDateLabel.text = "Laid date: \(Util.setDateAsString(date: self.bait.laidDate))"
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
