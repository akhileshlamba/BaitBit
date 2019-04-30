//
//  BaitFilterTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 30/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class BaitFilterTableViewController: UITableViewController {
    
    let sectionTitles = ["Time period", "Bait status", "Removed baits"]
    var titleDataSources = [[String]]()
    let periodTitles = ["Start date", "End date"]
    let statusTitles = ["Overdue", "Due soon", "Active"]
    let removedTitles = ["Taken", "Untouched"]

    override func viewDidLoad() {
        super.viewDidLoad()

        titleDataSources.append(periodTitles)
        titleDataSources.append(statusTitles)
        titleDataSources.append(removedTitles)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleDataSources[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell", for: indexPath) as! PeriodTableViewCell
            cell.icon.image = UIImage(named: titleDataSources[indexPath.section][indexPath.row])
            cell.label.text = titleDataSources[indexPath.section][indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! BaitFilterTableViewCell
            cell.icon.image = UIImage(named: titleDataSources[indexPath.section][indexPath.row])
            cell.label.text = titleDataSources[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
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
