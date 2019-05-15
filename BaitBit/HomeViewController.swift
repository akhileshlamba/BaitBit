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

    @IBOutlet weak var nearbyBaits: UIButton!
    @IBOutlet weak var reminder: UILabel!
    @IBOutlet weak var actionRequired: UITableView!
    @IBOutlet weak var recentlyViewed: UITableView!
    var sections = [String]()

    var user : User!

//    var isDueSoon: Bool! = false
//    var isOverDue: Bool! = false
//    var isDocumentationPending: Bool! = false
//    var isLicenseExpiring: Bool! = false

    var isSendNotificationForLicense: Bool! = false
    var isSendNotificationForBaits: Bool! = false
    var isSendNotificationForDocuments: Bool! = false

    var notifcationOfUser : [String: Any]!
    var documentsPending : [String : Int] = [:]
    var overDueBaitsForProgram : [String : Int] = [:]
    var dueSoonBaitsForProgram : [String : Int] = [:]
    var scheduledPrograms : [String: Int] = [:]
    
    var textForReminderOnHomeScreen = ""
    var flagForCreation = false
    var flagForSelection = false
    var countForSwitchBetweenOverDueAndDueSoon = 0
    var countForAction = 0
    
    var recentlyViewedPrograms = [String: Double]()
    var action = [String: Int]()
    
    var program : Program!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recentlyViewed.dataSource = self
        self.recentlyViewed.delegate = self
        
        self.actionRequired.dataSource = self
        self.actionRequired.delegate = self
        
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
        //checkForNotifications()

        self.setNavigationBarItems()

        self.getAllMyBaits()

    }

    func getAllMyBaits() {
        for program in self.user.programs.values {
            self.baits.append(contentsOf: program.baits.values)
        }
    }

//    func checkForNotifications(){
//
//        self.isDueSoon = self.notifcationOfUser["dueSoon"] as? Bool
//        self.isOverDue = self.notifcationOfUser["overDue"] as? Bool
//        self.isDocumentationPending = self.notifcationOfUser["documentation"] as? Bool
//        self.isLicenseExpiring = self.notifcationOfUser["license"] as? Bool
//    }
//
//
//
//
//    func calculateTotalNotifications(){
//        self.user = FirestoreDAO.authenticatedUser!
//        overDueBaitsForProgram = [:]
//        dueSoonBaitsForProgram = [:]
//        documentsPending = [:]
//        sections = []
//        if isOverDue {
//            for program in user.programs {
//                if program.value.isActive {
//                    var overDueBaits = 0
//                    var dueSoonBaits = 0
//                    for bait in program.value.baits {
//                        if bait.value.isOverdue {
//                            overDueBaits += 1
//                        }
//                    }
//                    if overDueBaits != 0 {
//                        overDueBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = overDueBaits
//                    }
//
//                }
//            }
//        }
//
//        if isDueSoon {
//            for program in user.programs {
//                if program.value.isActive {
//                    var overDueBaits = 0
//                    var dueSoonBaits = 0
//                    for bait in program.value.baits {
//                        if bait.value.isDueSoon {
//                            overDueBaits += 1
//                        }
//                    }
//                    if overDueBaits != 0 {
//                        dueSoonBaitsForProgram["\(program.value.id)%\(program.value.baitType as! String)"] = overDueBaits
//                    }
//                }
//            }
//        }
//
//        if isDocumentationPending {
//            for program in user.programs {
//                if program.value.isActive {
//                    if !program.value.documents.isEmpty {
//                        if program.value.areDocumentsPending {
//                            isSendNotificationForDocuments = true
//                            documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4 - program.value.documents.count
//                        }
//                    } else {
//                        documentsPending["\(program.value.id)%\(program.value.baitType as! String)"] = 4
//                    }
//                }
//            }
//        }
//
//
//
//        if dueSoonBaitsForProgram.count != 0 || overDueBaitsForProgram.count != 0{
//            isSendNotificationForBaits = true
//            sections.append("Bait Status")
//        }
//
//        if user.licenseExpiryDate != nil {
//            if isLicenseExpiring && user.licenseExpiringSoon {
//                isSendNotificationForLicense = true
//                sections.append("License")
//            }
//        } else {
//            sections.append("License")
//        }
//
//        if !documentsPending.isEmpty {
//            sections.append("Documentation")
//        }
//
//    }

//    func sendNotifications() {
//        let content = UNMutableNotificationContent()
//        content.title = "Movement Detected!"
//        content.subtitle = "You have entered"
//
//        if isSendNotificationForDocuments {
//            content.title = "Documents Pending"
//            content.subtitle = "Docs"
//        }
//
//        if isSendNotificationForLicense {
//            content.title = "License Expiring soon"
//            content.subtitle = "License expiring"
//        }
//
//        if isSendNotificationForBaits {
//            content.title = "Baits due or over due "
//            content.subtitle = "Some baits are either over due or due soon."
//        }
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//        let request = UNNotificationRequest(identifier: "Time done", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//
//
//    }

    @objc func logout() {
        // TODO: implement logout: embed the pop action inside logout action
        defaults.set(false, forKey: "loggedIn")
        defaults.set(nil, forKey: "userId")
        defaults.removeObject(forKey: "recentlyViewed")
        defaults.set(false, forKey: "setRemindersForAnimals")
        defaults.set(false, forKey: "scheduledProgramReminder")
        Reminder.removeAllNotifications()
        self.navigationController?.popViewController(animated: true)
    }

    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

//        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "notification"), style: .done, target: self, action: #selector(notification))



        self.tabBarController?.navigationItem.title = "Home"
    }

    func setNavigationBarItemsForGuest() {
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.hidesBackButton = false
        self.tabBarController?.navigationItem.title = "Home"
    }

//    @objc func notification() {
//        self.notifcationOfUser = FirestoreDAO.notificationDetails
//        isDueSoon = notifcationOfUser["dueSoon"] as? Bool
//        isOverDue = notifcationOfUser["overDue"] as? Bool
//        isDocumentationPending = notifcationOfUser["documentation"] as? Bool
//        isLicenseExpiring = notifcationOfUser["license"] as? Bool
//        if isDueSoon || isOverDue || isDocumentationPending || isLicenseExpiring {
//            performSegue(withIdentifier: "NotificationSegue", sender: nil)
//        } else {
//            displayMessage("You have disabled the notification feature", "Notifications")
//        }
//    }

    func loadData() {
        countForAction = 0
        countForSwitchBetweenOverDueAndDueSoon = 0
        let response = Notifications.calculateTotalNotifications(of: FirestoreDAO.authenticatedUser, with: FirestoreDAO.notificationDetails)
        
        if !response.isEmpty {
            overDueBaitsForProgram = response["overDue"] as! [String: Int]
            dueSoonBaitsForProgram = response["dueSoon"] as! [String: Int]
            documentsPending = response["documents"] as! [String: Int]
            scheduledPrograms = response["scheduledPrograms"] as! [String: Int]
            sections = response["sections"] as! [String]
        }
        self.actionRequired.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let loggedIn = UserDefaults.standard.bool(forKey:"loggedIn")
        if !loggedIn {
            self.setNavigationBarItemsForGuest()
            return
        }
        self.notifcationOfUser = FirestoreDAO.notificationDetails
//        checkForNotifications()
//        calculateTotalNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
        let loggedIn = UserDefaults.standard.bool(forKey:"loggedIn")
        if !loggedIn {
            self.setNavigationBarItemsForGuest()
            return
        }
        
        
        self.notifcationOfUser = FirestoreDAO.notificationDetails
//        checkForNotifications()
//        calculateTotalNotifications()
        
        self.setNavigationBarItems()
        
        // Notification for the current Month to be shown on home screen
        let current = UNUserNotificationCenter.current()
        current.getPendingNotificationRequests(completionHandler: {(requests) in
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day, .month, .year, .timeZone], from: Date())
            var flag = false
            for request in requests {
                if request.identifier == months[dateComponents.month!] {
                    DispatchQueue.main.async { [weak self] in
                        self!.reminder.text = request.content.body
                        //self?.tableView.reloadData()
                    }
                    flag = true
                    print(request.content.body)
                    self.textForReminderOnHomeScreen = request.content.body
                }
                
            }
            
            if !flag {
                DispatchQueue.main.async { [weak self] in
                    self!.reminder.text = "Reminders disabled for Baits Season"
                    //self?.tableView.reloadData()
                }
            }
        })
        
        self.user = FirestoreDAO.authenticatedUser!
        if self.defaults.dictionary(forKey: "recentlyViewed") != nil {
            recentlyViewedPrograms = self.defaults.dictionary(forKey: "recentlyViewed") as! [String : Double]
            self.recentlyViewed.reloadData()
        }
        
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
        
        if segue.identifier == "programActionSegue" {
            let controller = segue.destination as! ProgramDetailsViewController
            controller.program = program
            Program.program = controller.program
        }
        
        if segue.identifier == "licenseActionSegue" {
            let controller = segue.destination as! MoreTableViewController
            controller.user = user
        }

//        if segue.identifier == "NotificationSegue" {
//            let controller = segue.destination as! NotificationsTableViewController
//            controller.overDueBaitsForProgram = overDueBaitsForProgram
//            controller.dueSoonBaitsForProgram = dueSoonBaitsForProgram
//            controller.documentsPending = documentsPending
//            controller.sections = sections
//        }

    }

    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "recentlyViewed" {
            if recentlyViewedPrograms == nil || recentlyViewedPrograms.isEmpty {
                return 0
            } else {
                return recentlyViewedPrograms.count
            }
        } else {
            let license = FirestoreDAO.notificationDetails["license"] as? Bool
            var total = overDueBaitsForProgram.count + dueSoonBaitsForProgram.count + documentsPending.count + scheduledPrograms.count
            if user.licenseExpiryDate == nil || license! && user.licenseExpiringSoon {
                total += 1
            }
            if total == 0 {
                return 0
            } else if total == 1 {
                return 1
            } else {
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentlyViewed", for: indexPath)
        
        if tableView.restorationIdentifier == "recentlyViewed" {
            if recentlyViewedPrograms.isEmpty {
                return cell
            } else {
                let program = self.user.programs[Array(recentlyViewedPrograms.keys)[indexPath.row]]
                if program != nil {
                    cell.textLabel?.text = program?.baitType
                }
                return cell
            }
        } else {
            if countForAction < 2 {
                if !overDueBaitsForProgram.isEmpty && overDueBaitsForProgram.values.count > indexPath.row {
                    let count = Array(overDueBaitsForProgram.values)[indexPath.row]
                    let key = Array(overDueBaitsForProgram.keys)[indexPath.row]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "\(count) Baits over due in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                    flagForCreation = true
                    countForAction += 1
                } else  if !dueSoonBaitsForProgram.isEmpty && dueSoonBaitsForProgram.values.count > (indexPath.row - countForAction) {
                    let count = Array(dueSoonBaitsForProgram.values)[indexPath.row - countForAction]
                    let key = Array(dueSoonBaitsForProgram.keys)[indexPath.row - countForAction]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "warning")
                    cell.textLabel?.text = "\(count) Baits due Soon in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                    countForAction += 1
                }  else if !documentsPending.isEmpty && documentsPending.values.count > (indexPath.row - countForAction) {
                    let count = Array(documentsPending.values)[indexPath.row - countForAction]
                    let key = Array(documentsPending.keys)[indexPath.row - countForAction]
                    let name = key.split(separator: "%")[1]
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "\(count) Documents pending in \(name) program"
                    cell.textLabel?.numberOfLines = 2
                    countForAction += 1
                } else if !scheduledPrograms.isEmpty && scheduledPrograms.values.count > (indexPath.row - countForAction) {
                    let key = Array(scheduledPrograms.keys)[indexPath.row - countForAction]
                    let name = key.split(separator: "%")[1]
                    let id = String(key.split(separator: "%")[0])
                    let programs = user.programs
                    program = programs[id]
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "\(name) program starting on \(Util.setDateAsString(date: program.startDate))"
                    cell.textLabel?.numberOfLines = 2
                    countForAction += 1
                
                } else if user.licenseExpiryDate != nil {
                    
                    if FirestoreDAO.notificationDetails["license"] as! Bool {
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: user.licenseExpiryDate! as Date).day
                        if days! >= 0{
                            cell.textLabel?.text = "License expiring in \(days!) day(s) on \(Util.setDateAsString(date: user.licenseExpiryDate!))"
                        } else {
                            cell.textLabel?.text = "License is over due by \(days!) day(s) from  \(Util.setDateAsString(date: user.licenseExpiryDate!))"
                        }
                        
                        cell.imageView!.image = UIImage(named: "exclamation-mark")
                        cell.textLabel?.numberOfLines = 2
                        countForAction += 1
                    }
                    
                    
                } else {
                    cell.imageView!.image = UIImage(named: "exclamation-mark")
                    cell.textLabel?.text = "Please uplaod the Baiting License"
                    cell.textLabel?.numberOfLines = 2
                    countForAction += 1
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.restorationIdentifier == "recentlyViewed" {
            program = self.user.programs[Array(recentlyViewedPrograms.keys)[indexPath.row]]
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "programActionSegue", sender: nil)
        } else {
            countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
            if !overDueBaitsForProgram.isEmpty && overDueBaitsForProgram.values.count > indexPath.row{
                flagForSelection = true
                countForSwitchBetweenOverDueAndDueSoon = overDueBaitsForProgram.values.count
                let key = Array(overDueBaitsForProgram.keys)[indexPath.row]
                let id = String(key.split(separator: "%")[0])
                let programs = user.programs
                program = programs[id]
                tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "programActionSegue", sender: nil)
            } else if !dueSoonBaitsForProgram.isEmpty {
                let row = indexPath.row - countForSwitchBetweenOverDueAndDueSoon
                let key = Array(dueSoonBaitsForProgram.keys)[row]
                let id = String(key.split(separator: "%")[0])
                let programs = user.programs
                program = programs[id]
                tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "programActionSegue", sender: nil)
            } else if !documentsPending.isEmpty {
                let count = Array(documentsPending.values)[indexPath.row]
                let key = Array(documentsPending.keys)[indexPath.row]
                let id = String(key.split(separator: "%")[0])
                let name = key.split(separator: "%")[1]
                let programs = user.programs
                program = programs[id]
                tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "programActionSegue", sender: nil)
            } else if !scheduledPrograms.isEmpty {
                let key = Array(scheduledPrograms.keys)[indexPath.row]
                let id = String(key.split(separator: "%")[0])
                let name = key.split(separator: "%")[1]
                let programs = user.programs
                program = programs[id]
                tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "programActionSegue", sender: nil)
            }
            else {
                performSegue(withIdentifier: "licenseActionSegue", sender: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    
}
