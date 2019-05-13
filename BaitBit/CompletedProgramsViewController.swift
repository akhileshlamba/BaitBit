//
//  CompletedProgramsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 12/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class CompletedProgramsViewController: UIViewController {

    @IBOutlet weak var numOfPrograms: UILabel!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var minMax: UILabel!
    @IBOutlet weak var baitType: UILabel!
    @IBOutlet weak var usedTimes: UILabel!
    @IBOutlet weak var baitsTaken: UILabel!
    @IBOutlet weak var nonTargetedCarcass: UILabel!
    @IBOutlet weak var RemovedOverdue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadProgramList()
        self.applySpeciesFilter()
        self.setLabels()
        self.setPickView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapping))
        self.view.addGestureRecognizer(tap)
    }
    
    var programList: [Program] = []
    var filteredProgramList: [Program] = []
    
    func loadProgramList() {
        self.programList = Array(FirestoreDAO.authenticatedUser.programs.filter({ (element) -> Bool in
            return !element.value.isActive
        }).values)
    }
    
    func applySpeciesFilter() {
        if self.speciesTextField.text == self.speciesType[0] || self.speciesTextField.text == "" {
            self.filteredProgramList = self.programList
        } else {
            self.filteredProgramList = self.programList.filter({ (program) -> Bool in
                return program.species! == self.speciesTextField.text
            })
        }
    }
    
    func setLabels() {
        self.numOfPrograms.text = "\(self.programList.count)"
        if self.filteredProgramList.count > 0 {
            self.duration.text = "\(Analytics.averageDuration(programs: self.filteredProgramList) ?? 0) day(s)"
            self.minMax.text = "Min: \(Analytics.minDuration(programs: self.filteredProgramList) ?? 0) day(s) Max: \(Analytics.maxDuration(programs: self.filteredProgramList) ?? 0) day(s)"
            let bait = Analytics.mostUsedBait(programs: self.filteredProgramList)
            self.baitType.text = bait
            self.usedTimes.text = "Used in \(Analytics.numberOfPrograms(of: bait!, in: self.filteredProgramList)) out of \(self.filteredProgramList.count) program(s)"
            self.baitsTaken.text = "\(Int(Analytics.baitsTakenRate(programs: self.filteredProgramList) ?? 0) * 100)%"
            self.nonTargetedCarcass.text = "\(Analytics.numOfNontargetedCarcass(programs: self.filteredProgramList))"
            self.RemovedOverdue.text = "\(Analytics.numOfRemovedOverdue(programs: self.filteredProgramList))"
        } else {
            self.duration.text = "no data"
            self.minMax.text = ""
            self.baitType.text = "no data"
            self.usedTimes.text = ""
            self.baitsTaken.text = ""
            self.nonTargetedCarcass.text = ""
            self.RemovedOverdue.text = ""
        }
    }
    
    let speciesType: [String] = ["All animals", "Dog", "Pig", "Rabbit", "Fox"]
    var speciesPicker = UIPickerView()
    
    func setPickView() {
        self.speciesPicker.dataSource = self
        self.speciesPicker.delegate = self
        self.speciesTextField.inputView = self.speciesPicker
        self.speciesTextField.text = self.speciesType[0]
    }
    
    @objc func tapping() {
        self.view.endEditing(true)
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

extension CompletedProgramsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speciesType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return speciesType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.speciesTextField.text = speciesType[row]
        self.applySpeciesFilter()
        self.setLabels()
        self.view.endEditing(true)
    }
}
