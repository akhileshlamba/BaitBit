//
//  MoreTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 7/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {

    var items = [[String]]()
    var user : User!
    var notificationDetails = [String: Any]()
    var updatedNotificationDetails = [String: Any]()
    
    var images = [[String]]()
    
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
        
        items.append(["License"])
        items.append(["Completed Programs", "Scheduled Programs"])
        items.append(["Resources", "Quick Links"])
        items.append(["Notifications"])
        items.append(["Emergency"])
        
        images.append([""])
        images.append(["in-progress", "completed"])
        images.append(["resources", "external-link"])
        images.append(["notification"])
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        //        // Uncomment the following line to preserve selection between presentations
        //        // self.clearsSelectionOnViewWillAppear = false
        //
        //        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func callCustomerService(_ sender: Any) {
        guard let number = URL(string: "telprompt://136186") else { return }
        UIApplication.shared.open(number,options: [:], completionHandler:
            nil)
    }
    
    
    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "More"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.setNavigationBarItems()
        let loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !loggedIn {
            Util.displayErrorMessage(view: self, "You have to login to see more information", "Login Required")
            return
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        for cell in tableView.visibleCells {
//            if let notificationCell = cell as? NotificationsTableViewCell {
//                switch notificationCell.label.text {
//                case "Over Due":
//                    updatedNotificationDetails["overDue"] = notificationCell.toggle.isOn
//                    break
//                case "Due Soon":
//                    updatedNotificationDetails["dueSoon"] = notificationCell.toggle.isOn
//                    break
//                case "Documentation":
//                    updatedNotificationDetails["documentation"] = notificationCell.toggle.isOn
//                    break
//                case "License":
//                    updatedNotificationDetails["license"] = notificationCell.toggle.isOn
//                    break
//                default:
//                    break
//                }
//            }
//        }
//
//        if !NSDictionary(dictionary: updatedNotificationDetails).isEqual(to: notificationDetails){
//            FirestoreDAO.updateNotificationDetails(with: updatedNotificationDetails["id"] as! String, details: updatedNotificationDetails)
//            notificationDetails = updatedNotificationDetails
//            print(updatedNotificationDetails)
//        }
        
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
        }
        
        if indexPath.section == 4 {
            return tableView.dequeueReusableCell(withIdentifier: "emergency", for: indexPath)
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = items[indexPath.section][indexPath.row]
            cell.imageView!.image = UIImage(named: images[indexPath.section][indexPath.row])
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
        //        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        }
        
        if indexPath.section == 4 {
            return 120.0
        }
        
        else {
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "License"
        }
        
        if section == 1 {
            return "Programs"
        }
        
        if section == 2 {
            return "Help"
        }
        
        if section == 3 {
            return "Settings"
        }
        
        return "Emergency"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "licenseSegue", sender: nil)
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "completedProgramSegue", sender: nil)
            }
            if indexPath.row == 1 {
                performSegue(withIdentifier: "scheduledProgramSegue", sender: nil)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "resourcesSegue", sender: nil)
            }
            if indexPath.row == 1 {
                performSegue(withIdentifier: "quickLinksSegue", sender: nil)
            }
        }
        
        if indexPath.section == 3 {
            performSegue(withIdentifier: "settingsSegue", sender: nil)
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
        
        if segue.identifier == "settingsSegue" {
            let vc = segue.destination as! SettingsTableViewController
            //vc.user = FirestoreDAO.authenticatedUser!
        }
        
    }

}
