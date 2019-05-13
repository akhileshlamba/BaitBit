//
//  CompletedProgramDetailsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 12/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class CompletedProgramDetailsViewController: UIViewController {
    
    var program: Program!
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var baitType: UILabel!
    @IBOutlet weak var species: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var totalBaitsUsed: UILabel!
    @IBOutlet weak var baitsTakenRate: UILabel!
    @IBOutlet weak var numberOfNontargetedCarcass: UILabel!
    @IBOutlet weak var numberOfRemovedOverdue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setLabels()
    }
    
    func setLabels() {
        self.programImage.image = UIImage(named: self.program.species!)
        self.baitType.text = self.program.baitType
        self.species.text = self.program.species
        self.duration.text = self.program.durationFormatted
        self.startDate.text = "Start date: \( Util.setDateAsString(date:self.program.startDate))"
        self.endDate.text = "End date: \(Util.setDateAsString(date: self.program.endDate! as NSDate))"
        self.totalBaitsUsed.text = "\(self.program.numberOfAllBaits)"
        if self.program.numberOfAllBaits > 0 {
            self.baitsTakenRate.text = "\(Int(self.program.baitsTakenRate! * 100))%"
        } else {
            self.baitsTakenRate.text = ""
        }
        self.numberOfNontargetedCarcass.text = "\(self.program.numberOfNontargetedCarcass)"
        self.numberOfRemovedOverdue.text = "\(self.program.numberOfRemovedOverdue)"
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
