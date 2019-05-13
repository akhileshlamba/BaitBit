//
//  ResourcesTableViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 12/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class ResourcesTableViewController: UITableViewController {

    var sections = [String]()
    var images = [String]()
    
    var planning = [String: [String]]()
    var purchase = [String: [String]]()
    var baitUse = [String: [String]]()
    var postBaiting = [String: [String]]()
    
    var procedures = [[String: [String]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        sections.append("Planning")
        sections.append("Bait purchase and storage")
        sections.append("Bait use")
        sections.append("Post baiting")
        sections.append("Quick Links")
        
        images.append("planning")
        images.append("purchase")
        images.append("Bait_Blue")
        images.append("in-progress")
        images.append("external-link")
        
        loadPlanning()
        loadPurchase()
        loadBaitUse()
        loadPostBaiting()
        
        procedures.append(planning)
        procedures.append(purchase)
        procedures.append(baitUse)
        procedures.append(postBaiting)
        print(procedures)
    }
    
    func loadPlanning() {
        var temp = [String]()
        temp.append("Monitor the pest and non-target animal population. ")
        temp.append("Develop a pest control strategy.")
        temp.append("Identify the  potential risks in baiting.")
        temp.append("Put the appropriate risk management strategies in place.")
        temp.append("Notify all adjoining neighbours in writing and make a record of the notifications. ")
        temp.append("Put up appropriate signage in the required locations.")
        temp.append("Check if you are competent in the use of any equipment associated with using 1080 or PAPP baits.")
       
       let string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/bait-use-and-1080"
        
        planning[string] = temp
    }
    
    func loadPurchase() {
        var temp = [String]()
        temp.append("Check your authorisation to purchase (or be supplied with) and use 1080 or PAPP baits.")
        temp.append("Purchase your 1080 and PAPP baits from an accredited retailer and provided the correct documentation")
        temp.append("Transport and store in accordance with the directions on the product label and the relevant SDS.")
        
        let string = "http://agriculture.vic.gov.au/agriculture/farm-management/chemical-use/agricultural-chemical-use/bait-use-and-1080/further-information-on-1080-and-papp"
        
        purchase[string] = temp
    }
    
    func loadBaitUse() {
        var temp = [String]()
        temp.append("Implement your risk-management strategies.")
        temp.append("Lay baits in accordance with the directions on the product label and in accordance with minimum distances from dwellings, water bodies, domestic water supplies, boundary fences and public roads.")
        temp.append("Comply with the safety directions and first aid instructions on the product label and the relevant SDS.")
        
        let string = "http://agriculture.vic.gov.au/__data/assets/pdf_file/0003/263541/Directions-for-use-1080-and-PAPP.pdf"
        
        baitUse[string] = temp
    }
    
    func loadPostBaiting() {
        var temp = [String]()
        temp.append("Collect untaken or unused baits regularly and within the required timeframes.")
        temp.append("Remove and safely dispose poisoned animals within the required time frames.")
        temp.append("Remove and safely dispose of poisoned animals within the required time frames.")
        temp.append("Report poisoned non-targeted animal to the DEDJTR.")
        
        let string = "http://agriculture.vic.gov.au/__data/assets/pdf_file/0003/263541/Directions-for-use-1080-and-PAPP.pdf"
        
        postBaiting[string] = temp
    }
    

    @IBAction func openLink(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: "http://agriculture.vic.gov.au/__data/assets/pdf_file/0003/263541/Directions-for-use-1080-and-PAPP.pdf")!)
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourcesIdentifier", for: indexPath)
        cell.textLabel!.text = sections[indexPath.row]
        cell.imageView?.image = UIImage(named: images[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.row] == "Quick Links" {
            performSegue(withIdentifier: "quickLinksSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "checklistSegue", sender: nil)
        }
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
        if segue.identifier == "checklistSegue" {
            let controller = segue.destination as! CheckListTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                print(self.procedures[indexPath.row])
                controller.string = sections[indexPath.row]
                controller.list = self.procedures[indexPath.row]
            }
        }
    }
    

}
