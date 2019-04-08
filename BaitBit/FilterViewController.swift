//
//  FilterViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 7/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit

enum Month: Int, CaseIterable {
    case January = 1, February, March, April, May, June, July, August, September, October, November, December
}

class FilterViewController: UIViewController {

    var speciesPicker = UIPickerView()
    var yearPicker = UIPickerView()
    var monthPicker = UIPickerView()
    var speciesDataSource: [String] = ["(All animals)"]
    var yearDataSource: [String] = [] //["(All years)"]
    var monthDataSource: [String] = ["(All months)"]
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    var selectedYear: Int = 0
    var selectedMonth: Int = 0
    var selectedSpecies: String?
    
    var delegate: FilterUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        speciesTextField.inputView = speciesPicker
        
        yearPicker.dataSource = self
        yearPicker.delegate = self
        yearTextField.inputView = yearPicker
        
        monthPicker.dataSource = self
        monthPicker.delegate = self
        monthTextField.inputView = monthPicker
        
        // initialise yearDataSource
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: Date()))!

        let years = Array(0...4)
        for number in years {
            yearDataSource.append("\(year - number)")
        }
        
        // initialise monthDataSource
        for month in Month.allCases {
            monthDataSource.append("\(month)")
        }
        
        // initialise speciesDataSource
        for species in Species.allCases {
            speciesDataSource.append("\(species)")
        }
        
        reset()
    }
    
    @objc func reset() {
        yearTextField.text = yearDataSource[selectedYear]
        yearPicker.selectRow(selectedYear, inComponent: 0, animated: true)
        
        if selectedMonth != 0 {
            monthTextField.text = monthDataSource[selectedMonth]
        } else {
            monthTextField.text = ""
        }
        monthPicker.selectRow(selectedMonth, inComponent: 0, animated: false)
        
        speciesTextField.text = selectedSpecies ?? ""
    }
    
    @IBAction func search(_ sender: Any) {
        let y = yearPicker.selectedRow(inComponent: 0)
        let m = monthPicker.selectedRow(inComponent: 0)
        print(m)
        delegate!.updateData(yearIndex: y, monthIndex: m, species: speciesTextField.text ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if speciesTextField.isFirstResponder {
            return speciesDataSource.count
        } else if yearTextField.isFirstResponder {
            return yearDataSource.count
        } else {
            return monthDataSource.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if speciesTextField.isFirstResponder {
            if row == 0 {
                speciesTextField.text = ""
            } else {
                speciesTextField.text = speciesDataSource[row]
            }
        } else if yearTextField.isFirstResponder {
            yearTextField.text = yearDataSource[row]
        } else {
            if row == 0 {
                monthTextField.text = ""
            } else {
                monthTextField.text = monthDataSource[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if speciesTextField.isFirstResponder {
            return speciesDataSource[row]
        } else if yearTextField.isFirstResponder {
            return yearDataSource[row]
        } else {
            return monthDataSource[row]
        }
    }
}
