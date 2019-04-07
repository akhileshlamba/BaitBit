//
//  FilterViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 7/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    var speciesPicker = UIPickerView()
    var yearPicker = UIPickerView()
    let speciesDataSource: [String] = ["All species", "vulpes", "rabbits"]
    var yearDataSource: [String] = ["All years"]
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    
    var delegate: FilterUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        speciesTextField.inputView = speciesPicker
        yearPicker.dataSource = self
        yearPicker.delegate = self
        yearTextField.inputView = yearPicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: Date()))!

        var years = Array(1950...year)
        years.reverse()

        for year in years {
            yearDataSource.append("\(year)")
        }
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

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if speciesTextField.isFirstResponder {
            return speciesDataSource.count
        } else {
            return yearDataSource.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if speciesTextField.isFirstResponder {
            if row == 0 {
                speciesTextField.text = ""
            } else {
                speciesTextField.text = speciesDataSource[row]
            }
        } else {
            if row == 0 {
                yearTextField.text = ""
            } else {
                yearTextField.text = yearDataSource[row]
            }
        }
        
        //        if row == 0 {
        //            loadData()
        //        } else {
        //            loadData(species: speciesDataSource[row])
        //        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if speciesTextField.isFirstResponder {
            return speciesDataSource[row]
        } else {
            return yearDataSource[row]
        }
    }
}
