//
//  ProgramCompletedTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 28/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class ProgramCompletedTableViewController: UITableViewController {

    var programList: [Program] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadProgramList()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func reloadProgramList() {
//        loading.startAnimating()
        programList.removeAll()
        for program in FirestoreDAO.authenticatedUser.programs {
            if !program.value.isActive {
                programList.append(program.value)
            }
        }
        
        programList.sort { (left, right) -> Bool in
            return left.id > right.id
        }
        
//        self.loading.stopAnimating()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return programList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "programCell", for: indexPath)

        // Configure the cell...
        if programList.count != 0 {
            let a:Program = self.programList[indexPath.row]
            cell.textLabel?.text = a.baitType!
            cell.detailTextLabel?.text = Util.setDateAsString(date: a.startDate)
            if a.hasOverdueBaits {
                cell.imageView!.image = UIImage(named: "exclamation-mark")
            } else if a.hasDueSoonBaits {
                cell.imageView!.image = UIImage(named: "warning")
            } else {
                cell.imageView!.image = UIImage(named: "checked")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "CompletedProgramDetailSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if programList.count == 0 {
                return "There is no completed program."
            } else if programList.count == 1 {
                return "You have 1 completed program."
            } else {
                return "You have \(programList.count) completed programs."
            }
        }
        return nil
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CompletedProgramDetailSegue" {
            
        }
    }
    

}
