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

    var baits: [Baits_Info] = []
    private var context : NSManagedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
    }
    
    @objc func logout() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setNavigationBarItems() {
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.title = "Home"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    func fetchData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Baits_Info")
        do{
            baits = try context.fetch(fetchRequest) as! [Baits_Info]
        } catch  {
            fatalError("Failed to fetch animal list")
        }
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
            fetchData()
            for bait in baits {
                print(bait.program?.name)
            }
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.baits = baits
        }
    }
   

}
