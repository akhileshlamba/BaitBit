//
//  EditProgramViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 26/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class EditProgramViewController: UIViewController {

    var progrom: Program!
    @IBOutlet weak var baitTypeTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    
    var baitTypePicker = UIPickerView()
    var speciesPicker = UIPickerView()
    var baitTypes: [String] = []
    let speciesType: [String] = ["(Please Select)", "Dog", "Pig", "Rabbit", "Fox"]
    var alternateSpecies : [String] = []
    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        
        // set picker views
        baitTypes.append("(Please select Your Bait)")
        for baitType in BaitType.allCases {
            baitTypes.append(baitType.rawValue)
        }
        
        baitTypePicker.dataSource = self
        baitTypePicker.delegate = self
        
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        
        self.baitTypeTextField.inputView = baitTypePicker
        self.speciesTextField.inputView = speciesPicker
        
        self.speciesTextField.isEnabled = false
        
        self.baitTypeTextField.text = self.progrom.baitType
        self.speciesTextField.text = self.progrom.species
        
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func save() {
        guard self.baitTypeTextField.text != "" && self.speciesTextField.text != "" else {
            Util.displayErrorMessage(view: self, "Please select bait type and species before saving", "Error")
            return
        }
        self.progrom.baitType = self.baitTypeTextField.text
        self.progrom.species = self.speciesTextField.text
        Program.program = self.progrom
        FirestoreDAO.createOrUpdate(program: self.progrom, complete: {(success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    @IBAction func deleteProgram(_ sender: Any) {
        let id = self.progrom.id
        let program = self.progrom
        Util.confirmMessage(view: self, "Are you sure to delete the program", "Delete program", confirmAction: { (_) in
            FirestoreDAO.delete(program: self.progrom, complete: { (result) in
                if !result {
                    Util.displayErrorMessage(view: self, "Could not delete program due to internet connection issue", "Error")
                    return
                }
                Reminder.removePendingNotifications(for: "scheduledPrograms", programs: [program!])
                var recentlyViewed = self.defaults.dictionary(forKey: "recentlyViewed")
                recentlyViewed?.removeValue(forKey: id)
                self.defaults.set(recentlyViewed, forKey: "recentlyViewed")
                let controller = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
                self.navigationController?.popToViewController(controller!, animated: true)
            })
        }, cancelAction: nil)
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

extension EditProgramViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.baitTypeTextField.isFirstResponder {
            return baitTypes.count
        } else {
            return alternateSpecies.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.baitTypeTextField.isFirstResponder {
            if row == 0{
                self.baitTypeTextField.text = ""
            } else {
                alternateSpecies = []
                let speciesName = baitTypes[row]
                alternateSpecies.append("Select Animal")
                for a in speciesType {
                    if speciesName.contains(a){
                        alternateSpecies.append(a)
                    }
                }
                self.speciesTextField.isEnabled = true
                self.baitTypeTextField.text = baitTypes[row]
            }
        } else {
            if row == 0{
                self.speciesTextField.text = ""
            } else {
                self.speciesTextField.text = alternateSpecies[row]
            }
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.baitTypeTextField.isFirstResponder {
            return baitTypes[row]
        } else {
            return alternateSpecies[row]
        }
        
    }
}
