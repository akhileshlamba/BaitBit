//
//  BaitDetailsViewController.swift
//  BaitBit
//
//  Created by Xiaotian LIU on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class BaitDetailsViewController: UIViewController {
    
    var bait: Bait!
    @IBOutlet weak var dueTextField: UILabel!
    @IBOutlet weak var durationTextField: UILabel!
    @IBOutlet weak var startDateTextField: UILabel!
    @IBOutlet weak var baitImageView: UIImageView!
    @IBOutlet weak var baitDetailsTitleView: UIView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var baitImageContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    

    @IBAction func dragDownFromTop(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.edges == .top {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
