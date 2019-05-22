//
//  CompletedProgramsMapFilterTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 13/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

protocol CompletedProgramsMapFilterUpdateDelegate {
    func updateData(filters: (isTaken: Bool, isUntouched: Bool, noCarcassFound: Bool, targetCarcassFound: Bool, nontargetCarcassFound: Bool, isRemovedOverdue: Bool, isRemovedOnTime: Bool))
}

class CompletedProgramsMapFilterTableViewController: UITableViewController {

    let taken = ["Taken", "Untouched"]
    let carcass = ["No carcass found", "Targeted carcass", "Non-targeted carcass"]
    let due = ["Removed after due", "Removed on time"]
    var titles = [[String]]()
    var delegate: CompletedProgramsMapFilterUpdateDelegate?
    var filters: (isTaken: Bool, isUntouched: Bool, noCarcassFound: Bool, targetCarcassFound: Bool, nontargetCarcassFound: Bool, isRemovedOverdue: Bool, isRemovedOnTime: Bool)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.reset))
        
        if self.filters == nil {
            self.filters = (true, true, true, true, true, true, true)
        }
        
        self.titles.append(self.taken)
        self.titles.append(self.carcass)
        self.titles.append(self.due)
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reset() {
        self.filters = (true, true, true, true, true, true, true)
        self.tableView.reloadData()
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        for cell in tableView.visibleCells {
            let toggleIsOn = (cell as! BaitFilterTableViewCell).toggle.isOn
            let section = tableView.indexPath(for: cell)?.section
            let row = tableView.indexPath(for: cell)?.row
            switch section {
            case 0:
                switch row {
                case 0:
                    filters?.isTaken = toggleIsOn
                    break
                case 1:
                    filters?.isUntouched = toggleIsOn
                    break
                default:
                    break
                }
                break
            case 1:
                switch row {
                case 0:
                    filters?.noCarcassFound = toggleIsOn
                    break
                case 1:
                    filters?.targetCarcassFound = toggleIsOn
                    break
                case 2:
                    filters?.nontargetCarcassFound = toggleIsOn
                    break
                default:
                    break
                }
                break
            case 2:
                switch row {
                case 0:
                    filters?.isRemovedOverdue = toggleIsOn
                    break
                case 1:
                    filters?.isRemovedOnTime = toggleIsOn
                    break
                default:
                    break
                }
                break
            default:
                break
            }
        }
        delegate?.updateData(filters: self.filters!)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.titles[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapFilterCell", for: indexPath) as! BaitFilterTableViewCell

        // Configure the cell...
        cell.imageView?.image = UIImage(named: titles[indexPath.section][indexPath.row])
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.toggle.isOn = filters?.isTaken ?? true
                break
            case 1:
                cell.toggle.isOn = filters?.isUntouched ?? true
                break
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                cell.toggle.isOn = filters?.noCarcassFound ?? true
                break
            case 1:
                cell.toggle.isOn = filters?.targetCarcassFound ?? true
                break
            case 2:
                cell.toggle.isOn = filters?.nontargetCarcassFound ?? true
                break
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 0:
                cell.toggle.isOn = filters?.isRemovedOverdue ?? true
                break
            case 1:
                cell.toggle.isOn = filters?.isRemovedOnTime ?? true
                break
            default:
                break
            }
            break
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BaitFilterTableViewCell
        cell.toggle.isOn = !cell.toggle.isOn
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                filters?.isTaken = cell.toggle.isOn
                break
            case 1:
                filters?.isUntouched = cell.toggle.isOn
                break
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                filters?.noCarcassFound = cell.toggle.isOn
                break
            case 1:
                filters?.targetCarcassFound = cell.toggle.isOn
                break
            case 2:
                filters?.nontargetCarcassFound = cell.toggle.isOn
                break
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 0:
                filters?.isRemovedOverdue = cell.toggle.isOn
                break
            case 1:
                filters?.isRemovedOnTime = cell.toggle.isOn
                break
            default:
                break
            }
            break
        default:
            break
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
