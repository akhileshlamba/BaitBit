//
//  ProgramViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData

protocol AddProgramDelegate {
    func didAddBaitProgram(_ program : Program)
}

class AddProgramViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var species: UITextField!
    @IBOutlet weak var start_date: UITextField!
    var program: Program?
    
    let formatter = DateFormatter()
    var currentTextFieldTag : Int = 1
    
    var delegate : AddProgramDelegate?
    
    var alternateSpecies : [String] = []
    var animalList: [Program] = []
    
    var baitTypePicker = UIPickerView()
    var speciesPicker = UIPickerView()
    
    let baitTypes: [String] = ["(Please select Your Bait)", "Shelf-stable Rabbit Bait", "Shelf-stable Feral Pig Bait"
                                ,"Shelf-stable Fox or Wild Dog Bait", "Fox or Wild Dog capsule", "Perishable Fox Bait",
                                 "Perishable Wild Dog Bait", "Perishable Rabbit Bait"]
    
    let speciesType: [String] = ["(Please Select)", "Dog", "Pig", "Rabbit", "Fox"]
    
    
    let datePicker = UIDatePicker()
    
//    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baitTypePicker.dataSource = self
        baitTypePicker.delegate = self
        
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        
        name.inputView = baitTypePicker
        species.inputView = speciesPicker
        
        species.isEnabled = false
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        // Set current date to textfield
        start_date.text = formatter.string(from: Date())
        showDatePicker()
        
        
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
//        do{
//            animalList = try context.fetch(fetchRequest) as! [Bait_program]
//        } catch  {
//            fatalError("Failed to fetch animal list")
//        }
        
        
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
//        self.navigationItem.leftBarButtonItem?.tintColor = .red
    }

    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        context = (appDelegate?.persistentContainer.viewContext)!
//        super.init(coder: aDecoder)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        start_date.inputAccessoryView = toolbar
        start_date.inputView = datePicker
        
    }
    
    @objc func doneDatePicker(){
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
        if (name.text?.isEmpty)! || (start_date.text?.isEmpty)! || (species.text?.isEmpty)! {
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
            
            let timestamp = NSDate().timeIntervalSince1970 * 1000
        
            let program = Program(id: "\(timestamp)",
                                  baitType: name.text!,
                                  species: species.text!,
                                  startDate: formatter.date(from: start_date.text!)! as NSDate,
                                  isActive: true)
            
            do {
                delegate?.didAddBaitProgram(program)
                FirestoreDAO.createOrUpdate(program: program)
                
                if !(formatter.date(from: start_date.text!)!  > Date()) {
//                    performSegue(withIdentifier: "addbait", sender: nil)
                    performSegue(withIdentifier: "ProgramStartedSegue", sender: nil)
                } else {
//                    displayMessage("Program has been saved. Since you chose the future date, you cannot add baits.", "Program saved.")
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
            let controller = segue.destination as! AddBaitViewController
            controller.program = self.program
        }
        
        if segue.identifier == "ProgramStartedSegue" {
            let controller = segue.destination as! ProgramDetailsViewController
            controller.program = self.program
            
        }
    }

}

extension AddProgramViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if name.isFirstResponder {
            return baitTypes.count
        } else {
            return alternateSpecies.count
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if name.isFirstResponder {
            if row == 0{
                name.text = ""
            } else {
                alternateSpecies = []
                let speciesName = baitTypes[row]
                alternateSpecies.append("Select Animal")
                for a in speciesType {
                    if speciesName.contains(a){
                        alternateSpecies.append(a)
                    }
                }
                species.isEnabled = true
                name.text = baitTypes[row]
            }
        } else {
            if row == 0{
                species.text = ""
            } else {
                species.text = alternateSpecies[row]
            }
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if name.isFirstResponder {
            return baitTypes[row]
        } else {
            return alternateSpecies[row]
        }
        
    }
}