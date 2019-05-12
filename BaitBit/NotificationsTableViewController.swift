//
//  NotificationsTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    
    var users : User!
    var program : Program!
    
    var isDueSoon: Bool!
    var isOverDue: Bool!
    var isDocumentationPending: Bool!
    var isLicenseExpiring: Bool!
    
    var notifcationOfUser : [String: Any]!
    var overDueBaitsForProgram : [String : Int] = [:]
    var dueSoonBaitsForProgram : [String : Int] = [:]
    var documentsPending : [String : Int] = [:]
    
    var sections1 = [[String: Int]]()
    
    var sections = [String]()
    var flagForCreation = false
    var flagForSelection = false
    var countForSwitchBetweenOverDueAndDueSoon = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.notifcationOfUser = FirestoreDAO.notificationDetails
//        isDueSoon = notifcationOfUser["dueSoon"] as? Bool
//        isOverDue = notifcationOfUser["overDue"] as? Bool
//        isDocumentationPending = notifcationOfUser["documentation"] as? Bool
//        isLicenseExpiring = false
//
        self.users = FirestoreDAO.authenticatedUser
       
    }
    
    // MARK: - Table view data source

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if sections.count == 0 {
            return 1
        } else {
            return sections.count
        }
        
    }

    func loadData() {
        let response = Notifications.notifications
        
        if !response.isEmpty {
            overDueBaitsForProgram = response["overDue"] as! [String: Int]
            dueSoonBaitsForProgram = response["dueSoon"] as! [String: Int]
            documentsPending = response["documents"] as! [String: Int]
            sections = response["sections"] as! [String]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarItems()
        DispatchQueue.main.async { [weak self] in
            self!.loadData()
            self?.tableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.tableView.reloadData()
    }
    
    func setNavigationBarItems() {
        //        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filter))
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Notifications"
        //        self.navigationController?.hidesBarsOnTap = true
        //        self.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count : Int!
        if !sections.isEmpty {
            switch sections[section] {
            case "Bait Status":
                count = overDueBaitsForProgram.count + dueSoonBaitsForProgram.count
                break
            case "License":
                count = 1
                break
            case "Documentation":
                count = documentsPending.count
                break
            default:
                count = 1
            }
        } else {
            count = 0
        }
        
        
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationIdentifier", for: indexPath)
        
        if !sections.isEmpty {
            switch sections[indexPath.section] {
            case "Bait Status" :
                if !overDueBaitsForProgram.isEmpty && overDueBaitsForProgram.values.count > indexPath.row {
                    countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
                    let count = Array(overDueBaitsForProgram.values)[indexPath.row]
                    let key = Array(overDueBaitsForProgram.keys)[indexPath.row]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "\(count) Baits over due in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                    flagForCreation = true
                } else  if !dueSoonBaitsForProgram.isEmpty {
                    var row = indexPath.row
                    if flagForCreation {
                        row = indexPath.row - countForSwitchBetweenOverDueAndDueSoon
                    }
                    let count = Array(dueSoonBaitsForProgram.values)[row]
                    let key = Array(dueSoonBaitsForProgram.keys)[row]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "warning")
                    cell.textLabel?.text = "\(count) Baits due Soon in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                }
                break
                
            case "Documentation":
                if !documentsPending.isEmpty {
                    let count = Array(documentsPending.values)[indexPath.row]
                    let key = Array(documentsPending.keys)[indexPath.row]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "\(count) Documents pending in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                }
                break
            case "License":
                if users.licenseExpiryDate != nil {
                    let days = Calendar.current.dateComponents([.day], from: Date(), to: users.licenseExpiryDate! as Date).day
                    if days! >= 0{
                        cell.textLabel?.text = "License expiring in \(days!) day(s) on \(Util.setDateAsString(date: users.licenseExpiryDate!))"
                    } else {
                        cell.textLabel?.text = "License is over due by \(days!) day(s) from  \(Util.setDateAsString(date: users.licenseExpiryDate!))"
                    }
                    
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.numberOfLines = 2
                } else {
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "Please uplaod the Baiting License"
                    cell.textLabel?.numberOfLines = 2
                }
                break
            default:
                cell.textLabel?.text = "There are no new notifications"
                break
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title : String!
        if !sections.isEmpty {
            switch sections[section] {
            case "Bait Status":
                title = "Baits Status"
                break
            case "Documentation":
                title = "Documentation"
                break
            case "License":
                title = "License"
                break
            default:
                title = "No new notifications"
                break
            }
        } else {
            title = "No new notifications"
        }
        
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case "Bait Status":
            countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
            if !overDueBaitsForProgram.isEmpty && overDueBaitsForProgram.values.count > indexPath.row{
                flagForSelection = true
                countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
                let key = Array(overDueBaitsForProgram.keys)[indexPath.row]
                let id = String(key.split(separator: "%")[0])
                let programs = users.programs
                program = programs[id]
                self.tableView.deselectRow(at: indexPath, animated: true)
                
            } else if !dueSoonBaitsForProgram.isEmpty {
                let row = indexPath.row - countForSwitchBetweenOverDueAndDueSoon
                let key = Array(dueSoonBaitsForProgram.keys)[row]
                let id = String(key.split(separator: "%")[0])
                let programs = users.programs
                program = programs[id]
                self.tableView.deselectRow(at: indexPath, animated: true)
                //performSegue(withIdentifier: "notificationProgramSegue", sender: nil)
            }
            
            
//            let countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
//            if countForSwitchBetweenOverDueAndDueSoon > indexPath.row {
//                let key = Array(overDueBaitsForProgram.keys)[indexPath.row]
//                let id = String(key.split(separator: "%")[0])
//                let programs = users.programs
//                program = programs[id]
//            }else {
//                let key = Array(dueSoonBaitsForProgram.keys)[indexPath.row - countForSwitchBetweenOverDueAndDueSoon]
//                let id = String(key.split(separator: "%")[0])
//                let programs = users.programs
//                program = programs[id]
//            }
            performSegue(withIdentifier: "notificationProgramSegue", sender: nil)
            break
        case "Documentation":
            if !documentsPending.isEmpty {
                let count = Array(documentsPending.values)[indexPath.row]
                let key = Array(documentsPending.keys)[indexPath.row]
                let id = String(key.split(separator: "%")[0])
                let name = key.split(separator: "%")[1]
                let programs = users.programs
                program = programs[id]
                self.tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "notificationProgramSegue", sender: nil)
            }
            break
        case "License":
            performSegue(withIdentifier: "licenseNotificationSegue", sender: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            
            break
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
        if segue.identifier == "notificationProgramSegue" {
            let controller = segue.destination as! ProgramDetailsViewController
            controller.program = program
            Program.program = controller.program
        }
        
        if segue.identifier == "licenseNotificationSegue" {
            let controller = segue.destination as! MoreTableViewController
            controller.user = users
        }
    }
    

}
