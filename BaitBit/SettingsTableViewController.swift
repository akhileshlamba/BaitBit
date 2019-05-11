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
        
        items.append(["Over Due", "Due Soon", "Documentation", "License"])
        items.append(["Scheduled Programs"])
        items.append(["Dog", "Pig", "Fox", "Rabbit"])
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
                case "Scheduled Programs":
                    updatedNotificationDetails["scheduledPrograms"] = notificationCell.toggle.isOn
                    break
                case "Dog":
                    updatedNotificationDetails["dog"] = notificationCell.toggle.isOn
                    break
                case "Pig":
                    updatedNotificationDetails["pig"] = notificationCell.toggle.isOn
                    break
                case "Fox":
                    updatedNotificationDetails["fox"] = notificationCell.toggle.isOn
                    break
                case "Rabbit":
                    updatedNotificationDetails["rabbit"] = notificationCell.toggle.isOn
                    break
                default:
                    break
                }
            }
        }
        
        if !NSDictionary(dictionary: updatedNotificationDetails).isEqual(to: notificationDetails){
            FirestoreDAO.updateNotificationDetails(with: updatedNotificationDetails["id"] as! String, updated: updatedNotificationDetails, previous: notificationDetails)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath) as! NotificationsTableViewCell
        if indexPath.section == 0 {
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
        
        if indexPath.section == 1 {
            switch items[indexPath.section][indexPath.row] {
            case "Scheduled Programs":
                cell.label.text = items[indexPath.section][indexPath.row]
                if updatedNotificationDetails["scheduledPrograms"] != nil {
                    cell.toggle.isOn = updatedNotificationDetails["scheduledPrograms"] as! Bool
                } else {
                    cell.toggle.isOn = false
                }
                break
            default:
                break
            }
            return cell
        }
        
        if indexPath.section == 2 {
            switch items[indexPath.section][indexPath.row] {
            case "Dog":
                cell.label.text = items[indexPath.section][indexPath.row]
                if updatedNotificationDetails["dog"] != nil {
                    cell.toggle.isOn = updatedNotificationDetails["dog"] as! Bool
                } else {
                    cell.toggle.isOn = false
                }
                break
            case "Pig":
                cell.label.text = items[indexPath.section][indexPath.row]
                if updatedNotificationDetails["pig"] != nil {
                    cell.toggle.isOn = updatedNotificationDetails["pig"] as! Bool
                } else {
                    cell.toggle.isOn = false
                }
                break
            case "Fox":
                cell.label.text = items[indexPath.section][indexPath.row]
                if updatedNotificationDetails["fox"] != nil {
                    cell.toggle.isOn = updatedNotificationDetails["fox"] as! Bool
                } else {
                    cell.toggle.isOn = false
                }
                break
            case "Rabbit":
                cell.label.text = items[indexPath.section][indexPath.row]
                if updatedNotificationDetails["rabbit"] != nil {
                    cell.toggle.isOn = updatedNotificationDetails["rabbit"] as! Bool
                } else {
                    cell.toggle.isOn = false
                }
                break
            default:
                break
            }
            return cell
        }
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
//
//        if indexPath.section == 2 {
//            cell.textLabel?.text = items[indexPath.section][indexPath.row]
//        }
//
//        if indexPath.section == 3 {
//            cell.textLabel?.text = items[indexPath.section][indexPath.row]
//        }
//
        return cell
        
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Baits"
        }
        
        if section == 1 {
            return "Program"
        }
        
        if section == 2 {
            return "Bait Season"
        }
       
        return "Empty"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotificationsTableViewCell
        
        if cell.toggle.isOn {
            cell.toggle.isOn = false
        } else {
            cell.toggle.isOn = true
        }
        
//        if indexPath.section == 0 {
//
//            if cell.toggle.isOn {
//                cell.toggle.isOn = false
//            } else {
//                cell.toggle.isOn = true
//            }
//
//            switch cell.label.text {
//            case "Over Due":
//                updatedNotificationDetails["overDue"] = cell.toggle.isOn
//                break
//            case "Due Soon":
//                updatedNotificationDetails["dueSoon"] = cell.toggle.isOn
//                break
//            case "Documentation":
//                updatedNotificationDetails["documentation"] = cell.toggle.isOn
//                break
//            case "License":
//                updatedNotificationDetails["license"] = cell.toggle.isOn
//                break
//            default:
//                break
//            }
//
//        }
//
//        if indexPath.section == 1 {
//
//            if cell.toggle.isOn {
//                cell.toggle.isOn = false
//            } else {
//                cell.toggle.isOn = true
//            }
//
//            switch cell.label.text {
//            case "Scheduled Programs":
//                updatedNotificationDetails["scheduledPrograms"] = cell.toggle.isOn
//                break
//            default:
//                break
//            }
//
//        }
//
//        if indexPath.section == 2 {
//
//            if cell.toggle.isOn {
//                cell.toggle.isOn = false
//            } else {
//                cell.toggle.isOn = true
//            }
//
//            switch cell.label.text {
//            case "Dog":
//                updatedNotificationDetails["dog"] = cell.toggle.isOn
//                break
//            case "Pig":
//                updatedNotificationDetails["pig"] = cell.toggle.isOn
//                break
//            case "Fox":
//                updatedNotificationDetails["fox"] = cell.toggle.isOn
//                break
//            case "Rabbit":
//                updatedNotificationDetails["rabbit"] = cell.toggle.isOn
//                break
//            default:
//                break
//            }
//
//        }
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
