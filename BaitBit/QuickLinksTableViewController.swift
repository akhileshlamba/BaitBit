//
//  QuickLinksTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 13/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class QuickLinksTableViewController: UITableViewController {

    var list = [String: String]()
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/licenses-permits-and-forms/agricultural-chemical-users-permit"
        
        list[string] = "Apply for non-commercial license"
        
        string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/licenses-permits-and-forms/commercial-operator-licence"
        
        list[string] = "Apply for commercial license"
        
        string = "https://www.agsafe.org.au/documents/item/169"
        
        list[string] = "View list of bait retailers"
        
        string = "http://agriculture.vic.gov.au/__data/assets/pdf_file/0003/263541/Directions-for-use-1080-and-PAPP.pdf?v=2"
        
        list[string] =  "Directions of bait use"
        
        images.append("planning")
        images.append("license")
        images.append("bait_blue-1")
        images.append("direction")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func callCustomerService(_ sender: Any) {
        guard let number = URL(string: "telprompt://136186") else { return }
        UIApplication.shared.open(number,options: [:], completionHandler:
        nil)
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quickLinksIdentifier", for: indexPath)
        
        if indexPath.row == 0 {
            cell.imageView?.image = UIImage(named: images[indexPath.row])
            cell.textLabel?.text = "Apply for non-commercial license"
        }
        
        if indexPath.row == 1 {
            cell.imageView?.image = UIImage(named: images[indexPath.row])
            cell.textLabel?.text = "Apply for commercial license"
        }
        
        if indexPath.row == 2 {
            cell.imageView?.image = UIImage(named: images[indexPath.row])
            cell.textLabel?.text = "View list of bait retailers"
        }
        
        if indexPath.row == 3 {
            cell.imageView?.image = UIImage(named: images[indexPath.row])
            cell.textLabel?.text = "Directions of bait use"
        }
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var string = ""
        if indexPath.row == 0 {
            string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/licenses-permits-and-forms/agricultural-chemical-users-permit"
        }
        
        if indexPath.row == 1 {
            string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/licenses-permits-and-forms/commercial-operator-licence"
        }
        
        if indexPath.row == 2 {
            string = "https://www.agsafe.org.au/documents/item/169"
        }
        
        if indexPath.row == 3 {
            string = "http://agriculture.vic.gov.au/__data/assets/pdf_file/0003/263541/Directions-for-use-1080-and-PAPP.pdf?v=2"
        }
        UIApplication.shared.open(URL(string: string)!)
        tableView.deselectRow(at: indexPath, animated: true)
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
