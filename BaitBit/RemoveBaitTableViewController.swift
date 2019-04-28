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
    let death = ["Carcass found near by"]
    var dataSourceForCells = [[String]]()
    let identifiersForCells = ["BaitStatusCell", "SpeciesDeathCell"]
    let titleForHeaders = ["Bait status (Choose one)", "Species death (Optional)"]
    var bait: Bait!

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
    
    @IBAction func removeBait(_ sender: Any) {
        Util.confirmMessage(view: self, "You are going to remove this bait, please make sure everything is clear.", "Remove bait", confirmAction: { (_) in
            // TODO: remove bait, i.e. set bait.isRemove = true, then update to firestore,
            self.bait.isRemoved = true
            let controller = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
            self.navigationController?.popToViewController(controller!, animated: true)
        }, cancelAction: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.dataSourceForCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSourceForCells[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: self.identifiersForCells[indexPath.section], for: indexPath)
        cell.textLabel?.text = self.dataSourceForCells[indexPath.section][indexPath.row]

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.cellForRow(at: IndexPath(row: 1 - indexPath.row, section: indexPath.section))?.accessoryType = .none
        }
        
        if indexPath.section == 1 {
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
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
