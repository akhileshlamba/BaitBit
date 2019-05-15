//
//  ScheduledProgramsTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 29/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class ScheduledProgramsTableViewController: UITableViewController {

    var programsList = [Program]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadData() {
        let programs = FirestoreDAO.authenticatedUser.programs
        programsList = []
        if !programs.isEmpty {
            for program in programs as NSDictionary {
                let p = program.value as! Program
                if p.futureDate {
                    programsList.append(p)
                }
            }
        }
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return programsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleProgramsIdentifer", for: indexPath)
        cell.textLabel?.text = programsList[indexPath.row].baitType
        cell.detailTextLabel?.text = Util.setDateAsString(date: programsList[indexPath.row].startDate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if programsList.count == 0 {
            return "There are no scheduled programs"
        } else {
            return "There are \(programsList.count) scheduled program(s)"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "scheduledProgramDetails", sender: nil)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
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
        
        if segue.identifier == "scheduledProgramDetails" {
            let controller = segue.destination as! ProgramDetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                controller.program = self.programsList[indexPath.row]
                Program.program = controller.program
            }
        }
        
    }
    

}
