//
//  HomeViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 31/3/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

let months = [
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
]

class HomeViewController: UIViewController {

    var baits: [Bait] = []
    //private var context : NSManagedObjectContext
    let defaults = UserDefaults()
    @IBOutlet weak var baitingProgramView: UIView!
    @IBOutlet weak var newProgramButton: UIButton!

    var sections = [String]()

    var user : User!

    var isDueSoon: Bool! = false
    var isOverDue: Bool! = false
    var isDocumentationPending: Bool! = false
    var isLicenseExpiring: Bool! = false

    var isSendNotificationForLicense: Bool! = false
    var isSendNotificationForBaits: Bool! = false
    var isSendNotificationForDocuments: Bool! = false

    var notifcationOfUser : [String: Any]!
    var documentsPending : [String : Int] = [:]
    var overDueBaitsForProgram : [String : Int] = [:]
    var dueSoonBaitsForProgram : [String : Int] = [:]
    
    var textForReminderOnHomeScreen = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController?.setNavigationBarHidden(true, animated: true)

        let loggedIn = UserDefaults.standard.bool(forKey:"loggedIn")
        if !loggedIn {
            self.baitingProgramView.isHidden = true
            self.newProgramButton.isHidden = true
            self.setNavigationBarItemsForGuest()
            return
        }
        self.user = FirestoreDAO.authenticatedUser!
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()

        self.setNavigationBarItems()

        self.getAllMyBaits()

    }

    func getAllMyBaits() {
        for program in self.user.programs.values {
            self.baits.append(contentsOf: program.baits.values)
        }
    }

    func checkForNotifications(){

        self.isDueSoon = self.notifcationOfUser["dueSoon"] as? Bool
        self.isOverDue = self.notifcationOfUser["overDue"] as? Bool
        self.isDocumentationPending = self.notifcationOfUser["documentation"] as? Bool
        self.isLicenseExpiring = self.notifcationOfUser["license"] as? Bool
    }


    
    
    func calculateTotalNotifications(){
        self.user = FirestoreDAO.authenticatedUser!
        overDueBaitsForProgram = [:]
        dueSoonBaitsForProgram = [:]
        documentsPending = [:]
        sections = []
        if isOverDue {
            for program in user.programs {
                if program.value.isActive {
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
        }

        if isDueSoon {
            for program in user.programs {
                if program.value.isActive {
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
        }

        if isDocumentationPending {
            for program in user.programs {
                if program.value.isActive {
                    if !program.value.documents.isEmpty {
                        if program.value.areDocumentsPending {
                            isSendNotificationForDocuments = true
                            documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4 - program.value.documents.count
                        }
                    } else {
                        documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4
                    }
                } 
            }
        }
        
        

        if dueSoonBaitsForProgram.count != 0 || overDueBaitsForProgram.count != 0{
            isSendNotificationForBaits = true
            sections.append("Bait Status")
        }

        if user.licenseExpiryDate != nil {
            if isLicenseExpiring && user.licenseExpiringSoon {
                isSendNotificationForLicense = true
                sections.append("License")
            }
        } else {
            sections.append("License")
        }
        
        if !documentsPending.isEmpty {
            sections.append("Documentation")
        }

    }

    func sendNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Movement Detected!"
        content.subtitle = "You have entered"

        if isSendNotificationForDocuments {
            content.title = "Documents Pending"
            content.subtitle = "Docs"
        }

        if isSendNotificationForLicense {
            content.title = "License Expiring soon"
            content.subtitle = "License expiring"
        }

        if isSendNotificationForBaits {
            content.title = "Baits due or over due "
            content.subtitle = "Some baits are either over due or due soon."
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "Time done", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)


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

    func setNavigationBarItemsForGuest() {
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = false
        self.tabBarController?.navigationItem.title = "Home"
    }

    @objc func notification() {
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        isDueSoon = notifcationOfUser["dueSoon"] as? Bool
        isOverDue = notifcationOfUser["overDue"] as? Bool
        isDocumentationPending = notifcationOfUser["documentation"] as? Bool
        isLicenseExpiring = notifcationOfUser["license"] as? Bool
        if isDueSoon || isOverDue || isDocumentationPending || isLicenseExpiring {
            performSegue(withIdentifier: "NotificationSegue", sender: nil)
        } else {
            displayMessage("You have disabled the notification feature", "Notifications")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let loggedIn = UserDefaults.standard.bool(forKey:"loggedIn")
        if !loggedIn {
            self.setNavigationBarItemsForGuest()
            return
        }
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()
        calculateTotalNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let loggedIn = UserDefaults.standard.bool(forKey:"loggedIn")
        if !loggedIn {
            self.setNavigationBarItemsForGuest()
            return
        }
        self.notifcationOfUser = FirestoreDAO.notificationDetails
        checkForNotifications()
        calculateTotalNotifications()
        self.setNavigationBarItems()
        
        // Notification for the current Month to be shown on home screen
        let current = UNUserNotificationCenter.current()
        current.getPendingNotificationRequests(completionHandler: {(requests) in
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day, .month, .year, .timeZone], from: Date())
            for request in requests {
                if request.identifier == months[dateComponents.month!] {
                    print(request.content.body)
                    self.textForReminderOnHomeScreen = request.content.body
                }
                
            }
        })
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    required init?(coder aDecoder: NSCoder) {
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        context = (appDelegate?.persistentContainer.viewContext)!
//        super.init(coder: aDecoder)
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "baitsSegue" {
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.baits = baits
        }

        if segue.identifier == "NotificationSegue" {
            let controller = segue.destination as! NotificationsTableViewController
            controller.overDueBaitsForProgram = overDueBaitsForProgram
            controller.dueSoonBaitsForProgram = dueSoonBaitsForProgram
            controller.documentsPending = documentsPending
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
