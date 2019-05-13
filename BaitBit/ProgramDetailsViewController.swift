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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var programImage: UIImageView!
    
    @IBOutlet weak var docPendingLabel: UILabel!
    @IBOutlet weak var documnentsPending: UIButton!
    
    @IBOutlet weak var showActiveButton: UIButton!
    @IBOutlet weak var showOverdueButton: UIButton!
    @IBOutlet weak var showDueSoonButton: UIButton!
    
    var flag : Bool = false
    
    @IBOutlet weak var durationLabel: UILabel!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextFields()
        self.setRightBarButtonItem()
        
        // Recently viewed Items
        var recentlyViewed = defaults.dictionary(forKey: "recentlyViewed")
        if recentlyViewed == nil || recentlyViewed!.isEmpty {
            recentlyViewed = [String: Double]()
            recentlyViewed![self.program.id] = NSDate().timeIntervalSince1970
            defaults.set(recentlyViewed, forKey: "recentlyViewed")
        } else {
            if recentlyViewed!.count < 3 {
                recentlyViewed![self.program.id] = NSDate().timeIntervalSince1970
//                if (recentlyViewed?.keys.contains(self.program.id))! {
//                    recentlyViewed![self.program.id] = NSDate().timeIntervalSinceNow
//                } else {
//                    recentlyViewed![self.program.id] = NSDate().timeIntervalSinceNow
//                }
            } else {
                let temp = recentlyViewed?.min{a,b in (a.value as! Double) < (b.value as! Double)}
                recentlyViewed?.removeValue(forKey: temp!.key)
                recentlyViewed![self.program.id] = NSDate().timeIntervalSince1970
            }
            defaults.set(recentlyViewed, forKey: "recentlyViewed")
            print(recentlyViewed!.count)
            print(recentlyViewed)
        }
        
        
        if program.documents.count == 4 {
            docPendingLabel.text = "Documents"
        }
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
    }
    
    @objc func edit() {
        performSegue(withIdentifier: "EditProgramSegue", sender: nil)
    }
    
    @objc func endProgram() {
        if self.program.numberOfUnremovedBaits > 0 {
            Util.displayErrorMessage(view: self, "Please remove all baits and upload ducuments to end program", "Cannot end program")
        } else if self.program.documents.count < 4 {
            Util.displayErrorMessage(view: self, "Please upload ducuments to end program", "Cannot end program")
        }else {
            Util.confirmMessage(view: self, "Are you sure to END this program?", "End program", confirmAction: { (_) in
                self.program.isActive = false
                FirestoreDAO.end(program: self.program, complete: { (result) in
                    if result {
                        Util.displayMessage(view: self, "Program ended successfully", "Program Ended", "OK", completion: { (_) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }, cancelAction: nil)
        }
    }
    
    
    @IBAction func documentsPending(_ sender: Any) {
        performSegue(withIdentifier: "DocumentSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.program = FirestoreDAO.authenticatedUser.programs[program.id]
        self.updateTextFields()
        self.setRightBarButtonItem()
        if self.program.documents.count == 4 {
            docPendingLabel.text = "Documents"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if self.isMovingFromParentViewController {
//            self.back()
//        }
    }
    
    func setRightBarButtonItem() {
        if self.program.numberOfAllBaits == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End", style: .plain, target: self, action: #selector(self.endProgram))
        }
    }
    
    func setTextFields() {
        self.baitTypeTextField.text = self.program.baitType
        self.speciesTextField.text = self.program.species
        self.durationTextField.text = self.program.durationFormatted
        let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "MMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: self.program.startDate as Date)
        self.startDateTextField.text = "Start date: \(formattedDate)"
        self.totalBaitsTextField.text = "\(self.program.numberOfAllBaits)"

        if self.program.futureDate {
            self.addOrViewBaitButton.isHidden = true
            self.durationLabel.text = "Start In"
        }
        
        if self.program.numberOfAllBaits == 0 {
            self.addOrViewBaitButton.setTitle("Add Baits", for: .normal)
            self.numberOfRemovedBaitsTextField.text = ""
            self.hidesStatsView()
        } else {
            self.addOrViewBaitButton.setTitle("View Bait Map", for: .normal)
            self.numberOfActiveBaitsTextField.text = "\(self.program.numberOfActiveBaits)"
            self.numberOfOverdueBaitsTextField.text = "\(self.program.numberOfOverdueBaits)"
            self.numberOfDueSoonBaitsTextField.text = "\(self.program.numberOfDueSoonBaits)"
            self.numberOfRemovedBaitsTextField.text = "Removed baits: \(self.program.numberOfRemovedBaits)"
        }
        
        self.programImage.image = UIImage(named: self.program.species!)
    }
    
    func updateTextFields() {
        self.baitTypeTextField.text = self.program.baitType
        self.speciesTextField.text = self.program.species
        self.programImage.image = UIImage(named: self.program.species!)

        if self.program.numberOfAllBaits > 0 {
            self.showStatsView()
            self.addOrViewBaitButton.setTitle("View Bait Map", for: .normal)
            self.totalBaitsTextField.text = "\(self.program.numberOfAllBaits)"
            self.numberOfActiveBaitsTextField.text = "\(self.program.numberOfActiveBaits)"
            self.numberOfOverdueBaitsTextField.text = "\(self.program.numberOfOverdueBaits)"
            self.numberOfDueSoonBaitsTextField.text = "\(self.program.numberOfDueSoonBaits)"
            self.numberOfRemovedBaitsTextField.text = "Removed baits: \(self.program.numberOfRemovedBaits)"
        }
    }
    
    @objc func back() {
        let count = (self.navigationController?.viewControllers.count)!
        let controller = self.navigationController?.viewControllers[count - 2]
        
        if controller is AddProgramViewController {
            let homeViewController = self.navigationController?.viewControllers[count - 3]
            self.navigationController?.popToViewController(homeViewController!, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBOutlet weak var addOrViewBaitButton: UIButton!
    
    @IBOutlet weak var circleRed: UIImageView!
    @IBOutlet weak var circleGreen: UIImageView!
    @IBOutlet weak var circleOrange: UIImageView!
    @IBOutlet weak var activeBaits: UILabel!
    @IBOutlet weak var overdueBaits: UILabel!
    @IBOutlet weak var dueSoonBaits: UILabel!
    
//    func removeStatsView() {
//        self.circleGreen.removeFromSuperview()
//        self.circleRed.removeFromSuperview()
//        self.circleOrange.removeFromSuperview()
//        self.activeBaits.removeFromSuperview()
//        self.overdueBaits.removeFromSuperview()
//        self.dueSoonBaits.removeFromSuperview()
//        self.numberOfActiveBaitsTextField.removeFromSuperview()
//        self.numberOfOverdueBaitsTextField.removeFromSuperview()
//        self.numberOfDueSoonBaitsTextField.removeFromSuperview()
//    }
    
    func hidesStatsView() {
        self.circleGreen.isHidden = true
        self.circleRed.isHidden = true
        self.circleOrange.isHidden = true
        self.activeBaits.isHidden = true
        self.overdueBaits.isHidden = true
        self.dueSoonBaits.isHidden = true
        self.numberOfActiveBaitsTextField.isHidden = true
        self.numberOfOverdueBaitsTextField.isHidden = true
        self.numberOfDueSoonBaitsTextField.isHidden = true
        self.showActiveButton.isEnabled = false
        self.showOverdueButton.isEnabled = false
        self.showDueSoonButton.isEnabled = false
    }
    
    func showStatsView() {
        self.circleGreen.isHidden = false
        self.circleRed.isHidden = false
        self.circleOrange.isHidden = false
        self.activeBaits.isHidden = false
        self.overdueBaits.isHidden = false
        self.dueSoonBaits.isHidden = false
        self.numberOfActiveBaitsTextField.isHidden = false
        self.numberOfOverdueBaitsTextField.isHidden = false
        self.numberOfDueSoonBaitsTextField.isHidden = false
        self.showActiveButton.isEnabled = true
        self.showOverdueButton.isEnabled = true
        self.showDueSoonButton.isEnabled = true
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
        
        if segue.identifier == "EditProgramSegue" {
            let controller = segue.destination as! EditProgramViewController
            controller.progrom = self.program
        }
        
        if segue.identifier == "DocumentSegue" {
            let controller = segue.destination as! DocumentsTableViewController
            controller.program = self.program
            controller.userId = FirestoreDAO.authenticatedUser.id
        }
        
        if segue.identifier == "ActiveBaitsSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.program = self.program
            controller.filters = (nil, nil, false, false, true, false, false)
        }
        
        if segue.identifier == "OverdueBaitsSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.program = self.program
            controller.filters = (nil, nil, true, false, false, false, false)
        }
        
        if segue.identifier == "DueSoonBaitsSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.program = self.program
            controller.filters = (nil, nil, false, true, false, false, false)
            //(startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool
        }
        
    }
    

}
