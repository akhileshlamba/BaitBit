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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextFields()
        self.setRightBarButtonItem()
        
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
    }
    
    @objc func edit() {
        performSegue(withIdentifier: "EditProgramSegue", sender: nil)
    }
    
    @objc func endProgram() {
        if self.program.numberOfUnremovedBaits > 0 {
            Util.displayErrorMessage(view: self, "Please remove all baits and upload ducuments to end program", "Cannot end program")
        } else {
            Util.confirmMessage(view: self, "Are you sure to END this program?", "End program", confirmAction: { (_) in
                // TODO: Do something here
                // 1. set self.program.isActive = false
                // 2. invoke FirestoreDAO.endProgram(program:Program, complete: ((Bool) -> Void)?)
                //    inside this method, setData [users/user.id/programs/program.id/"isActive": false]] in firestore
                FirestoreDAO.end(program: self.program)
            }, cancelAction: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.program = Program.program
        self.updateTextFields()
        self.setRightBarButtonItem()
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
    }
    

}
