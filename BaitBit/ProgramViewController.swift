//
//  ProgramViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData

protocol newBaitProgramDelegate {
    func didAddBaitProgram(_ program : Bait_program)
}

class ProgramViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var species: UITextField!
    @IBOutlet weak var start_date: UITextField!
    var program: Bait_program?
    
    let formatter = DateFormatter()
    var currentTextFieldTag : Int = 1
    
    var defaults = UserDefaults.standard
    
    var delegate : newBaitProgramDelegate?
    
    var alternateSpecies : [String] = []
    var animalList: [Bait_program] = []
    var picker = UIPickerView()
    let baitTypes: [String] = ["Please select Your Bait", "Shelf-stable Rabbit Bait", "Shelf-stable Feral Pig Bait"
                                ,"Shelf-stable Fox or Wild Dog Bait", "Fox or Wild Dog capsule", "Perishable Fox Bait",
                                 "Perishable Wild Dog Bait", "Perishable Rabbit Bait"]
    
    let speciesType: [String] = ["Please Select", "Dog", "Pig", "Rabbit", "Fox"]
    
    
    let datePicker = UIDatePicker()
    
    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        name.inputView = picker
        species.inputView = picker
        
        name.delegate = self
        species.delegate = self
        
        name.tag = 1
        species.tag = 2
        
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        // Set current date to textfield
        start_date.text = formatter.string(from: Date())
        showDatePicker()
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
        do{
            animalList = try context.fetch(fetchRequest) as! [Bait_program]
        } catch  {
            fatalError("Failed to fetch animal list")
        }
        
        
        // Do any additional setup after loading the view.
    }

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        start_date.inputAccessoryView = toolbar
        start_date.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        if start_date.isFirstResponder {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            start_date.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    @IBAction func addProgram(_ sender: Any) {
        if (name.text?.isEmpty)! || (start_date.text?.isEmpty)! || (species.text?.isEmpty)!{
            displayMessage("You have not entered value in any one field. Please Try again", "Save Failed")
        } else {
            let speciesName = species.text
            let baitName = name.text
            
            if !(baitName!.contains(speciesName!)) {
                displayMessage("Inavlid Bait for selected Species", "Invalid Selection")
                return
            }
            
            let defaults = UserDefaults.standard
            defaults.setValue(true, forKey:"program_counter")
        
            program = NSEntityDescription.insertNewObject(forEntityName: "Bait_program", into: context) as! Bait_program
            program?.name = name.text
            program?.program_id = Int64(defaults.integer(forKey: "baits_program_counter") + 1)
            program?.species = species.text
            program?.start_date = formatter.date(from: start_date.text!)! as NSDate
            program?.active = true
            
            do {
                try context.save()
                defaults.set(defaults.integer(forKey: "baits_program_counter") + 1, forKey: "baits_program_counter")
                delegate?.didAddBaitProgram(program!)
                
                if !(formatter.date(from: start_date.text!)!  > Date()) {
                    performSegue(withIdentifier: "addbait", sender: nil)
                } else {
                    displayMessage("Since you chose the future date, you cannot add baits", "Bait Add issue")
                }
                
            } catch let error {
                print("Could not save to core data: \(error)")
            }
        }
        
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addbait" {
            let controller = segue.destination as! BaitsViewController
            controller.program = self.program
        }
    }

}

extension ProgramViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextFieldTag == 1 {
            return baitTypes.count
        }
        if currentTextFieldTag == 2 {
            return alternateSpecies.count
        }
        
        return 0;
        
//        if species.isFirstResponder{
//            return speciesType.count
//        }
//        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextFieldTag == 1 {
            alternateSpecies = []
            let speciesName = baitTypes[row]
            alternateSpecies.append("Select Animal")
            for a in speciesType {
                if speciesName.contains(a){
                    alternateSpecies.append(a)
                }
            }
            
            name.text = baitTypes[row]
            
        }
        if currentTextFieldTag == 2 {
            species.text = alternateSpecies[row]
        }
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextFieldTag == 1 {
            return baitTypes[row]
        }
        if currentTextFieldTag == 2 {
            return alternateSpecies[row]
        }
        
       return ""
        
//        if species.isFirstResponder{
//            return baitTypes[row]
//        }
//        return "";
    }
}

extension ProgramViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            currentTextFieldTag = textField.tag
        }
        if textField.tag == 2 {
            currentTextFieldTag = textField.tag
        }
        picker.reloadAllComponents()
        return true
    }
}
