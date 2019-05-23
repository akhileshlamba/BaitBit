//
//  RemoveBaitTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 24/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class RemoveBaitTableViewController: UITableViewController {
    
    let status = ["Taken", "Untouched"]
    let death = ["No carcass found", "Targeted carcass found near by", "Non-targeted carcass found near by"]
    var dataSourceForCells = [[String]]()
    let identifiersForCells = ["BaitStatusCell", "SpeciesDeathCell"]
    let titleForHeaders = ["Bait status (Choose one)", "Species death (Optional)"]
    var bait: Bait!
    
    var isTaken: Bool?
    var carcassFound: Bool?
    var targetCarcassFound: Bool?
    
    let checked: [Bool:UITableViewCellAccessoryType] = [true:.checkmark, false:.none]

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSourceForCells.append(self.status)
        self.dataSourceForCells.append(self.death)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func removeBait(_ sender: UIButton) {
        guard self.isTaken != nil else {
            Util.displayErrorMessage(view: self, "Please specify whether the bait was taken.", "Error")
            return
        }
        
        if self.isTaken! && self.carcassFound == nil {
            self.carcassFound = false
        }
        
        Util.confirmDestructiveActionMessage(view: self, "Are you sure to remove this bait?", "Remove bait", actionTitle: "Remove") { (_) in
            sender.isEnabled = false
            self.loading.startAnimating()
            
            // remove bait, i.e. set bait.isRemove = true, then update to firestore,
            self.bait.isRemoved = true
            self.bait.removedDate = Date()
            self.bait.isTaken = self.isTaken
            self.bait.carcassFound = self.carcassFound
            self.bait.targetCarcassFound = self.targetCarcassFound
            FirestoreDAO.remove(bait: self.bait, from: self.bait.program!, complete: { (success) in
                self.loading.stopAnimating()
                if !success {
                    sender.isEnabled = true
                    Util.displayErrorMessage(view: self, "Unable to remove bait due to internet connetion issue", "Error")
                    return
                }
                if success {
                    let controller = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
                    self.navigationController?.popToViewController(controller!, animated: true)
                } else {
                    
                }
            })
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let taken = self.isTaken {
            if taken {
                return 2
            } else {
                return 1
            }
        }
        return 1
//        return self.dataSourceForCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSourceForCells[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: self.identifiersForCells[indexPath.section], for: indexPath)
        cell.textLabel?.text = self.dataSourceForCells[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.accessoryType = checked[self.isTaken ?? false]!
            } else {
                cell.accessoryType = checked[!(self.isTaken ?? true)]!
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.accessoryType = checked[!(self.carcassFound ?? true)]!
                break
            case 1:
                cell.accessoryType = checked[self.targetCarcassFound ?? false]!
                break
            case 2:
                cell.accessoryType = checked[!(self.targetCarcassFound ?? true)]!
                break
            default:
                break
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.cellForRow(at: IndexPath(row: 1 - indexPath.row, section: indexPath.section))?.accessoryType = .none
            self.isTaken = (indexPath.row == 0)
            if !self.isTaken! {
                self.carcassFound = nil
                self.targetCarcassFound = nil
            }
            self.tableView.reloadData()
        }
        
        if indexPath.section == 1 {
            for i in 0...2 {
                if i == indexPath.row {
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .checkmark
                } else {
                    tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                }
            }
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//                tableView.cellForRow(at: indexPath)?.accessoryType = .none
//            } else {
//                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            }
            switch indexPath.row {
            case 0:
                self.carcassFound = false
                self.targetCarcassFound = nil
                break
            case 1:
                self.carcassFound = true
                self.targetCarcassFound = true
                break
            case 2:
                self.carcassFound = true
                self.targetCarcassFound = false
                break
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaders[section]
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
