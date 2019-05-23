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
            self.baitsTaken.text = "\(Int((Analytics.baitsTakenRate(programs: self.filteredProgramList) ?? 0) * 100))%"
            self.baitsTaken.font = self.baitsTaken.font.withSize(27)
            self.nonTargetedCarcass.text = "\(Analytics.numOfNontargetedCarcass(programs: self.filteredProgramList))"
            self.nonTargetedCarcass.font = self.nonTargetedCarcass.font.withSize(27)
            self.RemovedOverdue.text = "\(Analytics.numOfRemovedOverdue(programs: self.filteredProgramList))"
            self.RemovedOverdue.font = self.RemovedOverdue.font.withSize(27)
        } else {
            self.duration.text = ""
            self.minMax.text = "No programs"
            self.baitType.text = ""
            self.usedTimes.text = "No programs"
            self.baitsTaken.text = "No\nprograms"
            self.baitsTaken.font = self.baitsTaken.font.withSize(12)
            self.nonTargetedCarcass.text = "No\nprograms"
            self.nonTargetedCarcass.font = self.nonTargetedCarcass.font.withSize(12)
            self.RemovedOverdue.text = "No\nprograms"
            self.RemovedOverdue.font = self.RemovedOverdue.font.withSize(12)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MapForAllCompletedProgramsSegue" {
            let controller = segue.destination as! CompletedProgramsMapViewController
            controller.baits = self.getAllBaits(from: self.filteredProgramList)
        }
        
        if segue.identifier == "BaitsTakenSegue" {
            let controller = segue.destination as! CompletedProgramsMapViewController
            controller.baits = self.getAllBaits(from: self.filteredProgramList)
            controller.filters = (true, false, true, true, true, true, true)
        }
        
        if segue.identifier == "NontargetedCarcassSegue" {
            let controller = segue.destination as! CompletedProgramsMapViewController
            controller.baits = self.getAllBaits(from: self.filteredProgramList)
            controller.filters = (true, false, false, false, true, true, true)
        }
        
        if segue.identifier == "RemovedOverdueSegue" {
            let controller = segue.destination as! CompletedProgramsMapViewController
            controller.baits = self.getAllBaits(from: self.filteredProgramList)
            controller.filters = (true, true, true, true, true, true, false)
        }
    }
    
    func getAllBaits(from programs: [Program]) -> [Bait] {
        var baits = [Bait]()
        programs.forEach { (program) in
            baits.append(contentsOf: program.baits.values)
        }
        return baits
    }

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
