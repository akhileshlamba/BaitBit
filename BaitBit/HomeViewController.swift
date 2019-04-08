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
            let controller = segue.destination as! BaitsProgramMapViewController
            controller.baits = baits
        }
    }
   

}
