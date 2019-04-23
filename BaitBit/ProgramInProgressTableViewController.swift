//
//  BaitProgramTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 6/4/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData

class ProgramInProgressTableViewController: UITableViewController, AddProgramDelegate {

    var programList: [Bait_program] = []
    private var context : NSManagedObjectContext
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bait_program")
        do {
            programList = try context.fetch(fetchRequest) as! [Bait_program]
//            divideDataIntoSection()
        } catch  {
            fatalError("Failed to fetch animal list")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    func divideDataIntoSection(){
//        list.removeAll()
//        var activeList: [Bait_program] = []
//        var inactiveList: [Bait_program] = []
//        for bait_program in programList {
//            if bait_program.active{
//                activeList.append(bait_program)
//            } else {
//                inactiveList.append(bait_program)
//            }
//        }
//        list.append(activeList)
//        list.append(inactiveList)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //tableView.reloadData()
        let cell = tableView.dequeueReusableCell(withIdentifier: "programBait", for: indexPath) as! ProgramTableViewCell
        
        
        if programList.count != 0 {
            let a:Bait_program = self.programList[indexPath.row]
            cell.textLabel?.text = a.name!
            cell.detailTextLabel?.text = dateFormatter.string(from: a.start_date! as Date)
            
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
//        label.backgroundColor = UIColor.lightGray
//        label.font = label.font.withSize(20)
//        label.text = self.sections[section]
//        return label
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Programs in-progress"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 && programList.count == 0 {
            return "(There is no programs in progress.)"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let program = self.programList[indexPath.row]
        if program.start_date! as Date > Date() {
            displayMessage("Since you chose the future date, you cannot add baits", "Bait Add issue")
        } else {
            performSegue(withIdentifier: "ProgramDetailSegue", sender: nil)
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60.0
//    }
    
    func didAddBaitProgram(_ program: Bait_program) {
        programList.append(program)
        self.tableView.reloadData()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ProgramMapSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                controller.program = self.programList[indexPath.row]
            }
        }
        
        if segue.identifier == "AddProgramSegue" {
            let controller = segue.destination as! AddProgramViewController
            controller.delegate = self
        }
    }
}
