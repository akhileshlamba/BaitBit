//
//  SecondPageViewController.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 31/3/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit

class SecondPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func start(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.setValue(true, forKey:"skipTutorialPages")
        defaults.synchronize()
    }
}
