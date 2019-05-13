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

    @IBOutlet weak var loading: UIActivityIndicatorView!
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
        loading.startAnimating()
        programList.removeAll()
        for program in FirestoreDAO.authenticatedUser.programs {
            if program.value.isActive && !program.value.futureDate{
                programList.append(program.value)
            }
        }
        
        programList.sort { (left, right) -> Bool in
            return left.id > right.id
        }
        
        self.loading.stopAnimating()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItems()
        self.reloadProgramList()
    }

    func setNavigationBarItems() {
                self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Program", style: .plain, target: self, action: #selector(addProgram))
        //self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "In-progress Programs"
        //        self.navigationController?.hidesBarsOnTap = true
        //        self.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    @objc func addProgram() {
        // TODO: implement logout: embed the pop action inside logout action
        performSegue(withIdentifier: "AddProgramSegue", sender: nil)
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
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        let label = UILabel.init(frame: CGRect.init(x: 20, y: 20, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//        label.font = UIFont(name: "Serbino Regular", size: 12)
//        label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
//        label.textColor = .gray
//        label.sizeToFit()
//        headerView.addSubview(label)
//        headerView.sizeToFit()
//        return headerView
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if programList.count == 0 {
                return "There is no program in progress"
            } else if programList.count == 1 {
                return "You have 1 program in progress"
            } else {
                return "You have \(programList.count) programs in progress"
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.font = headerView.textLabel?.font.withSize(13)
        headerView.textLabel?.textColor = .gray
        headerView.textLabel?.text = self.tableView(self.tableView, titleForHeaderInSection: section)
//        headerView.textLabel?.numberOfLines = 0
//        headerView.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
//        headerView.textLabel?.textAlignment = NSTextAlignment.left
    }
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        if section == 0 {
//            if programList.count == 0 {
//                return "There is no program in progress"
//            } else if programList.count == 1 {
//                return "You have 1 program in progress"
//            } else {
//                return "You have \(programList.count) programs in progress"
//            }
//        }
//        return nil
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let program = self.programList[indexPath.row]
        if program.startDate as Date > Date() {
            displayMessage("Since you chose the future date, you cannot add baits", "Bait Add issue")
        } else {
            performSegue(withIdentifier: "ProgramDetailSegue", sender: nil)
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60.0
//    }
    
    func didAddBaitProgram(_ program: Program) {
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
        if segue.identifier == "ProgramDetailSegue" {
            let controller = segue.destination as! ProgramDetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                controller.program = self.programList[indexPath.row]
                Program.program = controller.program
            }
        }
        
        if segue.identifier == "AddProgramSegue" {
            let controller = segue.destination as! AddProgramViewController
            controller.delegate = self
        }
    }
}
