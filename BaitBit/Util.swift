//
//  Util.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 25/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    static var formatter = DateFormatter()
    static let dateFormat = "MMM dd, yyyy"
    
    
    static func setDateAsString(date: NSDate) -> String {
        formatter.dateFormat = dateFormat
        return formatter.string(from: date as! Date)
    }
    
    static func convertStringToDate(string: String) -> NSDate {
        formatter.dateFormat = dateFormat
        return formatter.date(from: string)! as NSDate
    }
    
    static func displayErrorMessage(view: UIViewController, _ message: String, _ title: String) {
        displayErrorMessage(view: view, message, title, completion: nil)
    }
    
    static func displayErrorMessage(view: UIViewController, _ message: String, _ title: String, completion: ((UIAlertAction) -> Void)?) {
        displayMessage(view: view, message, title, "Dismiss", completion: completion)
    }
    
    static func displayMessage(view: UIViewController, _ message: String, _ title: String, _ actionTitle: String) {
        displayMessage(view: view, message, title, actionTitle, completion: nil)
    }
    
    static func displayMessage(view: UIViewController, _ message: String, _ title: String, _ actionTitle: String, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style:
            UIAlertActionStyle.default, handler: completion))
        view.present(alertController, animated: true, completion: nil)
    }
    
    static func confirmMessage(view: UIViewController, _ message: String, _ title: String, confirmAction: ((UIAlertAction) -> Void)?, cancelAction: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            UIAlertActionStyle.default, handler: confirmAction))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: cancelAction))
        view.present(alertController, animated: true, completion: nil)
    }

}
