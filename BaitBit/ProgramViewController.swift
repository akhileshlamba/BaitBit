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
    @IBOutlet weak var start_date: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var limit: UITextField!
    
    var delegate : newBaitProgramDelegate?
    
    var animalList: [Bait_program] = []
    var picker = UIPickerView()
    let dataSource: [String] = ["All species", "Shelf-stable Rabbit Bait", "Shelf-stable Feral Pig Bait"
                                ,"Shelf-stable Fox or Wild Dog Bait", "Fox or Wild dog capsule", "Perishable Fox Bait",
                                 "Perishable Wild Dog Bait", "Perishable Rabbit Bait"]
    
    let datePicker = UIDatePicker()
    
    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        name.inputView = picker
        showDatePicker()
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
        do{
            animalList = try context.fetch(fetchRequest) as! [Bait_program]
            print("asdasdsduhqd qwod hqw")
            print(animalList.count)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        if start_date.isFirstResponder {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            start_date.text = formatter.string(from: datePicker.date)
        }
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    @IBAction func addProgram(_ sender: Any) {
        if (name.text?.isEmpty)! || (limit.text?.isEmpty)! || (start_date.text?.isEmpty)! || (duration.text?.isEmpty)!{
            displayMessage("You have not entered value in any one field. Please Try again", "Save Failed")
        } else {
            var list : [Bait_program] = []
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
            let predicate = NSPredicate(format: "name = \(String(describing: name.text))")
            fetchRequest.predicate = predicate
            do{
                list = try context.fetch(fetchRequest) as! [Bait_program]
            } catch  {
                fatalError("Failed to fetch animal list")
            }
            
            if list.count > 0{
                displayMessage("This program is already active", "Duplicate record")
                return
            } else {
                let program = NSEntityDescription.insertNewObject(forEntityName: "Bait_program", into: context) as! Bait_program
                program.name = name.text
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-mm-yyyy" //Your date format
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+10:00") //Current time zone
                //according to date format your date string
                //            guard let start_date = dateFormatter.date(from: start_date.text!) else {
                //                fatalError()
                //            }
                
                program.start_date = NSDate()
                program.active = true
                do {
                    try context.save()
                    delegate?.didAddBaitProgram(program)
                    //                let vc = BaitsViewController()
                    //                self.present(vc, animated: true, completion: nil)
                    performSegue(withIdentifier: "addbait", sender: nil)
                } catch let error {
                    print("Could not save to core data: \(error)")
                }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProgramViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        name.text = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
