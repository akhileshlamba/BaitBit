//
//  Reminder.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 10/5/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import UserNotifications

class Reminder: NSObject {
    
    static var defaults = UserDefaults.standard
    
    static func removePendingNotifications(for type: String, programs: [Program]?) {
        let center = UNUserNotificationCenter.current()
        
        if type == "animal" {
            center.removePendingNotificationRequests(withIdentifiers: ["January", "February", "March", "April", "May", "August", "September", "October", "November", "December"])
            defaults.set(false, forKey: "setRemindersForAnimals")
        }
        
        if type == "scheduledPrograms" {
            var list = [String]()
            if !programs!.isEmpty && programs!.count > 0{
                for program in programs! {
                    list.append(program.id)
                }
            }
            center.removePendingNotificationRequests(withIdentifiers: list)
        }
    }
    
    static func removeAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    static func setOrUpdateRemindersForAnimals(notifications notifications: [String: Any]) {
        
        
        if !defaults.bool(forKey: "setRemindersForAnimals") {
            for i in 1...12 {
                setRemindersForAnimals(month: i, notifications: notifications)
            }
            defaults.set(true, forKey: "setRemindersForAnimals")
        }
        
    }
    
    static func setRemindersForAnimals(month: Int, notifications: [String: Any]) {
        let isDogNotificationActive = notifications["dog"] as! Bool
        let isPigNotificationActive = notifications["pig"] as! Bool
        let isFoxNotificationActive = notifications["fox"] as! Bool
        let isRabbitNotificationActive = notifications["rabbit"] as! Bool
        
        var text = ""
        switch month {
        case 1:
            //pigs
            if isPigNotificationActive {
                text = "Pigs"
            }
            
            if text != "" {
                setNotificationRequest(month: 1, text: text, identifier: "January")
            }
            
            break
        case 2:
            //rabbits, pigs
            
            if isRabbitNotificationActive {
                text = "Rabbits"
            }
            
            if isPigNotificationActive {
                if text != "" {
                    text = text + ", Pigs"
                } else {
                    text = "Pigs"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 2, text: text, identifier: "February")
            }
            
            break
        case 3:
            // rabbots, dogs, fox
            if isRabbitNotificationActive {
                text = "Rabbits"
            }
            
            if isDogNotificationActive {
                if text != "" {
                    text = text + ", Dogs"
                } else {
                    text = "Dogs"
                }
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 3, text: text, identifier: "March")
            }
            
            break
        case 4:
            // rabbots, dogs, fox
            
            if isRabbitNotificationActive {
                text = "Rabbits"
            }
            
            if isDogNotificationActive {
                if text != "" {
                    text = text + ", Dogs"
                } else {
                    text = "Dogs"
                }
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 4, text: text, identifier: "April")
            }
            
            break
        case 5:
            //dogs, fox
            
            if isDogNotificationActive {
                text = text + "Dogs"
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 5, text: text, identifier: "May")
            }
            
            break
        case 8:
            //fox
            
            if isFoxNotificationActive {
                text = text + "Fox"
            }
            
            if text != "" {
                setNotificationRequest(month: 8, text: text, identifier: "August")
            }
            
            break
        case 9:
            //dogs, fox
            
            if isDogNotificationActive {
                text = text + "Dogs"
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 9, text: text, identifier: "September")
            }
            
            break
        case 10:
            //dogs, fox
            
            if isDogNotificationActive {
                text = text + "Dogs"
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
            }
            
            if text != "" {
                setNotificationRequest(month: 10, text: text, identifier: "October")
            }
            
            break
        case 11:
            //dogs, fox
            
            if isDogNotificationActive {
                text = text + "Dogs"
            }
            
            if isFoxNotificationActive {
                if text != "" {
                    text = text + ", Fox"
                } else {
                    text = "Fox"
                }
                
            }
            
            if text != "" {
                setNotificationRequest(month: 11, text: text, identifier: "November")
            }
            
            break
        case 12:
            //pigs
            
            if isPigNotificationActive {
                text = "Pigs"
            }
            
            if text != "" {
                setNotificationRequest(month: 12, text: text, identifier: "December")
            }
            
            break
        default:
            break
        }
        
    }
    
    static func setNotificationRequest(month month: Int, text text: String, identifier identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Bait Time"
        content.body = "It is best time to bait for \(text) now"
        
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.timeZone = TimeZone.current
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
    }
    
    static func scheduledProgramReminder(for program: Program) {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: program.startDate as Date).day
        
        let content = UNMutableNotificationContent()
        content.title = program.baitType!
        var dateComponents = DateComponents()
        if days! >= 2 {
            content.body = "Program due in 2 days on \(Util.setDateAsString(date: program.startDate))"
            let dayComp = DateComponents(day: -2)
            let date = Calendar.current.date(byAdding: dayComp, to: program.startDate as Date)
            dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date!)
        } else {
            content.body = "Program due in 1 day on \(Util.setDateAsString(date: program.startDate))"
            let dayComp = DateComponents(day: -1)
            let date = Calendar.current.date(byAdding: dayComp, to: program.startDate as Date)
            dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date!)
        }
        
        dateComponents.hour = 12
        dateComponents.timeZone = TimeZone.current
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        print(trigger.nextTriggerDate())
        
        let request = UNNotificationRequest(identifier: program.id,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: nil)
        defaults.set(true, forKey: "scheduledProgramReminder")
    }
    
    static func scheduledProgramReminder(for programs: [Program]) {
        for program in programs {
            scheduledProgramReminder(for: program)
        }
    }
    
}
