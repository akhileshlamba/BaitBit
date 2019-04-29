//
//  DocumentsTableViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 24/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

let documentNames = ["Risk assessment", "Purchase record", "Notification of pest control", "Neighbour notification"]
let documentImageNames = ["Risk assessment", "Document_Green", "Notification of pest", "Neighbour_Notif"]

protocol SegueDelegate {
    func getDocument(data : Documents)
}

class DocumentsTableViewController: UITableViewController, DocumentUploadDelegate {

    var program : Program!
    var userId : String!
    var documentName: String!
    
    var fromCreateAdd : Bool! = false
    
    var delegate: SegueDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        
        cell.textLabel?.text = documentNames[indexPath.row]
        cell.imageView?.image = UIImage(named: documentImageNames[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        documentName = documentNames[indexPath.row]
        self.performSegue(withIdentifier: "UploadDocument", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !fromCreateAdd {
            self.program = FirestoreDAO.authenticatedUser.programs[program.id]
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        if segue.identifier == "UploadDocument" {
            let controller = segue.destination as! DocumentUploadViewController
            if fromCreateAdd {
                controller.uploadDelegate = self
                controller.fromCreateAdd = true
                controller.userId = userId
                controller.documentName = documentName
            } else {
                var document : Documents!
                if program.documents.count != 0 {
                    for doc in program.documents {
                        if doc!.name == documentName {
                            document = doc
                        }
                    }
                }
                
                controller.program = self.program
                controller.userId = userId
                controller.document = document
                controller.documentName = documentName
            }
        }
    }
    
    func documentData(data: Documents) {
        delegate.getDocument(data: data)
    }
    

}
