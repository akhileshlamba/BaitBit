//
//  BaitFilterTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 30/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

protocol BaitFilterUpdateDelegate {
    func updateData(filters: (startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool))
}

class BaitFilterTableViewController: UITableViewController {
    
    let sectionTitles = ["Time period", "Bait status", "Removed baits"]
    var titleDataSources = [[String]]()
    let periodTitles = ["Start date", "End date"]
    let statusTitles = ["Overdue", "Due soon", "Active"]
    let removedTitles = ["Taken", "Untouched"]

    var delegate: BaitFilterUpdateDelegate?
    var filters: (startDate: Date?, endDate: Date?, showOverdue: Bool, showDueSoon: Bool, showActive: Bool, showTaken: Bool, showUntouched: Bool)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleDataSources.append(periodTitles)
        titleDataSources.append(statusTitles)
        titleDataSources.append(removedTitles)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.reset))
        
        // initialise filters
        if filters == nil {
            self.filters = (nil, nil, true, true, true, true, true)
        }
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reset() {
        self.filters = (nil, nil, true, true, true, true, true)
        self.tableView.reloadData()
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        for cell in self.tableView.visibleCells {
            
        }
        delegate?.updateData(filters: self.filters!)
        self.navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count - 1 // change back after finish date picker
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleDataSources[section + 1].count // change back after finish date picker
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == -1 { // change back after finish date picker
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell", for: indexPath) as! PeriodTableViewCell
            cell.icon.image = UIImage(named: titleDataSources[indexPath.section][indexPath.row])
            cell.label.text = titleDataSources[indexPath.section + 1][indexPath.row] // change back after finish date picker
            if indexPath.row == 0 {
                if let startDate = filters?.startDate {
                    cell.dateTextField.text = Util.setDateAsString(date: startDate as NSDate)
                } else {
                    cell.dateTextField.text = ""
                }
            } else {
                if let endDate = filters?.endDate {
                    cell.dateTextField.text = Util.setDateAsString(date: endDate as NSDate)
                } else {
                    cell.dateTextField.text = ""
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! BaitFilterTableViewCell
            cell.icon.image = UIImage(named: titleDataSources[indexPath.section + 1][indexPath.row]) // change back after finish date picker
            cell.label.text = titleDataSources[indexPath.section + 1][indexPath.row] // change back after finish date picker
            cell.toggle.isEnabled = false
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    cell.toggle.isOn = filters?.showOverdue ?? true
                    break
                case 1:
                    cell.toggle.isOn = filters?.showDueSoon ?? true
                    break
                case 2:
                    cell.toggle.isOn = filters?.showActive ?? true
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    cell.toggle.isOn = filters?.showTaken ?? true
                    break
                case 1:
                    cell.toggle.isOn = filters?.showUntouched ?? true
                    break
                default:
                    break
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section + 1] // change back after finish date picker
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > -1 { // change back after finish date picker
            let cell = tableView.cellForRow(at: indexPath) as! BaitFilterTableViewCell
            cell.toggle.isOn = !cell.toggle.isOn
            if indexPath.section == 0 { // change back after finish date picker
                switch indexPath.row {
                case 0:
                    filters?.showOverdue = cell.toggle.isOn
                    break
                case 1:
                    filters?.showDueSoon = cell.toggle.isOn
                    break
                case 2:
                    filters?.showActive = cell.toggle.isOn
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    filters?.showTaken = cell.toggle.isOn
                    break
                case 1:
                    filters?.showUntouched = cell.toggle.isOn
                    break
                default:
                    break
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
