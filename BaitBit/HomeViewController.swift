//
//  HomeViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 31/3/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    var baits: [Bait] = []
    private var context : NSManagedObjectContext
    let defaults = UserDefaults()
    
    var sections = [String]()
    
    var user : User!
    
    var isDueSoon: Bool!
    var isOverDue: Bool!
    var isDocumentationPending: Bool!
    var isLicenseExpiring: Bool!
    
    var notifcationOfUser : [String: Any]!
    var overDueBaitsForProgram : [String : Int] = [:]
    var dueSoonBaitsForProgram : [String : Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.user = FirestoreDAO.authenticatedUser!
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()
        
        
        self.setNavigationBarItems()
        
        
        
    }
    
    func checkForNotifications(){
        
        self.isDueSoon = self.notifcationOfUser["dueSoon"] as? Bool
        self.isOverDue = self.notifcationOfUser["overDue"] as? Bool
        self.isDocumentationPending = self.notifcationOfUser["documentation"] as? Bool
        self.isLicenseExpiring = self.notifcationOfUser["license"] as? Bool
    }
    
    
    func calculateTotalNotifications(of user: User){
        overDueBaitsForProgram = [:]
        dueSoonBaitsForProgram = [:]
        sections = []
        if isOverDue {
            for program in user.programs {
                var overDueBaits = 0
                var dueSoonBaits = 0
                for bait in program.value.baits {
                    if bait.value.isOverdue {
                        overDueBaits += 1
                    }
                }
                if overDueBaits != 0 {
                    overDueBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = overDueBaits
                }
            }
        }
        
        if isDueSoon {
            for program in user.programs {
                var overDueBaits = 0
                var dueSoonBaits = 0
                for bait in program.value.baits {
                    if bait.value.isDueSoon {
                        overDueBaits += 1
                    }
                }
                if overDueBaits != 0 {
                    dueSoonBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = overDueBaits
                }
            }
        }
        
        
        
        if dueSoonBaitsForProgram.count != 0 || overDueBaitsForProgram.count != 0{
            sections.append("Bait Status")
        }
        
        if isLicenseExpiring && user.licenseExpiringSoon{
            sections.append("License")
        }
        
        if isDocumentationPending {
            //sections.append("Documentation")
        }
        
        
        
    }
    
    @objc func logout() {
        // TODO: implement logout: embed the pop action inside logout action
        defaults.set(false, forKey: "loggedIn")
        defaults.set(nil, forKey: "userId")
        self.navigationController?.popViewController(animated: true)
    }
    
    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "notification"), style: .done, target: self, action: #selector(notification))
        
        
        self.tabBarController?.navigationItem.title = "Home"
    }
    
    @objc func notification() {
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        isDueSoon = notifcationOfUser["dueSoon"] as? Bool
        isOverDue = notifcationOfUser["overDue"] as? Bool
        isDocumentationPending = notifcationOfUser["documentation"] as? Bool
        isLicenseExpiring = notifcationOfUser["license"] as? Bool
        if isDueSoon || isOverDue || isDocumentationPending {
            performSegue(withIdentifier: "NotificationSegue", sender: nil)
        } else {
            displayMessage("You have disabled the notification feature", "Notifications")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()
        calculateTotalNotifications(of: FirestoreDAO.authenticatedUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()
        calculateTotalNotifications(of: FirestoreDAO.authenticatedUser)
        self.setNavigationBarItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "baitsSegue" {
            baits = []
            for program in user.programs {
                for bait in program.value.baits {
                    baits.append(bait.value)
                }
            }
            for bait in baits {
                print(bait.program?.baitType)
            }
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.baits = baits
        }
        
        if segue.identifier == "NotificationSegue" {
            let controller = segue.destination as! NotificationsTableViewController
            controller.overDueBaitsForProgram = overDueBaitsForProgram
            controller.dueSoonBaitsForProgram = dueSoonBaitsForProgram
            controller.sections = sections
        }
        
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
   

}
