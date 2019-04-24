//
//  ProgramDetailsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class ProgramDetailsViewController: UIViewController {

    var program: Program!
    @IBOutlet weak var baitTypeTextField: UILabel!
    @IBOutlet weak var speciesTextField: UILabel!
    @IBOutlet weak var durationTextField: UILabel!
    @IBOutlet weak var startDateTextField: UILabel!
    @IBOutlet weak var totalBaitsTextField: UILabel!
    @IBOutlet weak var numberOfRemovedBaitsTextField: UILabel!
    @IBOutlet weak var numberOfActiveBaitsTextField: UILabel!
    @IBOutlet weak var numberOfOverdueBaitsTextField: UILabel!
    @IBOutlet weak var numberOfDueSoonBaitsTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextFields()
        
        // Do any additional setup after loading the view.
    }
    
    func setTextFields() {
        self.baitTypeTextField.text = self.program.baitType
        self.speciesTextField.text = self.program.species
        self.durationTextField.text = self.program.durationFormatted
        let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "MMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: self.program.startDate as Date)
        self.startDateTextField.text = "Start date: \(formattedDate)"
        self.totalBaitsTextField.text = "\(self.program.numberOfAllBaits)"

        
        if self.program.numberOfAllBaits == 0 {
            self.addOrViewBaitButton.setTitle("Add Baits", for: .normal)
            self.numberOfRemovedBaitsTextField.text = ""
            self.removeStatsView()
        } else {
            self.addOrViewBaitButton.setTitle("View Bait Map", for: .normal)
            self.numberOfActiveBaitsTextField.text = "\(self.program.numberOfActiveBaits)"
            self.numberOfOverdueBaitsTextField.text = "\(self.program.numberOfOverdueBaits)"
            self.numberOfDueSoonBaitsTextField.text = "\(self.program.numberOfDueSoonBaits)"
            self.numberOfRemovedBaitsTextField.text = "Removed baits: \(self.program.numberOfRemovedBaits)"
        }
    }
    
    @IBOutlet weak var addOrViewBaitButton: UIButton!
    
    @IBOutlet weak var circleRed: UIImageView!
    @IBOutlet weak var circleGreen: UIImageView!
    @IBOutlet weak var circleOrange: UIImageView!
    @IBOutlet weak var activeBaits: UILabel!
    @IBOutlet weak var overdueBaits: UILabel!
    @IBOutlet weak var dueSoonBaits: UILabel!
    
    func removeStatsView() {
        self.circleGreen.removeFromSuperview()
        self.circleRed.removeFromSuperview()
        self.circleOrange.removeFromSuperview()
        self.activeBaits.removeFromSuperview()
        self.overdueBaits.removeFromSuperview()
        self.dueSoonBaits.removeFromSuperview()
        self.numberOfActiveBaitsTextField.removeFromSuperview()
        self.numberOfOverdueBaitsTextField.removeFromSuperview()
        self.numberOfDueSoonBaitsTextField.removeFromSuperview()
    }
    
    @IBAction func addOrViewBait(_ sender: Any) {
        if self.program.numberOfAllBaits == 0 {
            performSegue(withIdentifier: "AddBaitSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "ViewMapSegue", sender: nil)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewMapSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.program = program
        }
        
        if segue.identifier == "AddBaitSegue" {
            let controller = segue.destination as! AddBaitViewController
            controller.program = program
        }
    }
    

}
