//
//  SettingsTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 23/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var items = [[String]]()
    var user : User!
    var notificationDetails = [String: Any]()
    var updatedNotificationDetails = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItems()

        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            Util.displayErrorMessage(view: self, "You have to login to see more information", "Login Required")
            return
        }
        self.user = FirestoreDAO.authenticatedUser
        notificationDetails = FirestoreDAO.notificationDetails
        updatedNotificationDetails = notificationDetails
        
//        if !updatedNotificationDetails.isEmpty {
//            notificationDetails = updatedNotificationDetails
//        }
        
        items = [[String]]()
        
        items.append(["Notifications"])
        items.append(["Over Due", "Due Soon", "Documentation", "License"])
        self.tableView.tableFooterView = UIView(frame: .zero)
        
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        self.setNavigationBarItems()
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            Util.displayErrorMessage(view: self, "You have to login to see more information", "Login Required")
            return
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for cell in tableView.visibleCells {
            if let notificationCell = cell as? NotificationsTableViewCell {
                switch notificationCell.label.text {
                case "Over Due":
                    updatedNotificationDetails["overDue"] = notificationCell.toggle.isOn
                    break
                case "Due Soon":
                    updatedNotificationDetails["dueSoon"] = notificationCell.toggle.isOn
                    break
                case "Documentation":
                    updatedNotificationDetails["documentation"] = notificationCell.toggle.isOn
                    break
                case "License":
                    updatedNotificationDetails["license"] = notificationCell.toggle.isOn
                    break
                default:
                    break
                }
            }
        }
        
        if !NSDictionary(dictionary: updatedNotificationDetails).isEqual(to: notificationDetails){
            FirestoreDAO.updateNotificationDetails(with: updatedNotificationDetails["id"] as! String, details: updatedNotificationDetails)
            notificationDetails = updatedNotificationDetails
            print(updatedNotificationDetails)
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! UserProfileTableViewCell
            
            cell.avatar.image = UIImage(named: "user")
            cell.username.text = user.username as! String
            if user.licenseExpiryDate != nil {
                cell.viewLicense.text = "View License"
            } else {
                cell.viewLicense.text = "Add License"
            }
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath) as! NotificationsTableViewCell
            switch items[indexPath.section][indexPath.row] {
            case "Over Due":
                cell.label.text = items[indexPath.section][indexPath.row]
                cell.toggle.isOn = updatedNotificationDetails["overDue"] as! Bool
                break
            case "Due Soon":
                cell.label.text = items[indexPath.section][indexPath.row]
                cell.toggle.isOn = updatedNotificationDetails["dueSoon"] as! Bool
                break
            case "Documentation":
                cell.label.text = items[indexPath.section][indexPath.row]
                cell.toggle.isOn = updatedNotificationDetails["documentation"] as! Bool
                break
            case "License":
                cell.label.text = items[indexPath.section][indexPath.row]
                cell.toggle.isOn = updatedNotificationDetails["license"] as! Bool
                break
            default:
                break
            }
            return cell
        }
        
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        } else {
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else {
            return "Notification Settings"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "licenseSegue", sender: nil)
        }
        
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! NotificationsTableViewCell
            if cell.toggle.isOn {
                cell.toggle.isOn = false
            } else {
                cell.toggle.isOn = true
            }
            
            switch cell.label.text {
            case "Over Due":
                updatedNotificationDetails["overDue"] = cell.toggle.isOn
                break
            case "Due Soon":
                updatedNotificationDetails["dueSoon"] = cell.toggle.isOn
                break
            case "Documentation":
                updatedNotificationDetails["documentation"] = cell.toggle.isOn
                break
            case "License":
                updatedNotificationDetails["license"] = cell.toggle.isOn
                break
            default:
                break
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
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
        
        if segue.identifier == "licenseSegue" {
            let vc = segue.destination as! ProfileViewController
            //vc.user = FirestoreDAO.authenticatedUser! 
        }
        
    }
    

}
