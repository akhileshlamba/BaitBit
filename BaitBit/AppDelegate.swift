//
//  AppDelegate.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 30/3/19.
//  Copyright © 2019 The Hawks. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge, UNAuthorizationOptions.sound], completionHandler: {(authorized, error) in
            if authorized {
                
            } else {
                
            }
        })
        
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        let defaults = UserDefaults.standard
        let skipTutorialPages = defaults.bool(forKey:"skipTutorialPages")
        
        
        let startCounter = defaults.bool(forKey:"program_counter")
        
        if !startCounter{
            defaults.set(0, forKey: "baits_program_counter")
        }
        
        FirebaseApp.configure()
        
        if skipTutorialPages
        {
            let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            
            let mainView: HomeViewController = mainStoryBoard.instantiateViewController(withIdentifier: "SecondViewController") as! HomeViewController
            
            window?.rootViewController = mainView
            
        } else {
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.red
        }
        
//        let loggedIn = defaults.bool(forKey:"loggedIn")
//        if loggedIn {
//            let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
//            let mainView: TabBarViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//            let settingsVC = mainView.viewControllers![mainView.viewControllers!.count-1] as! SettingsTableViewController
//            
//            
//            
//            FirestoreDAO.getUserData(from: defaults.string(forKey: "userId")!, complete: {(user) in
//                settingsVC.user = user
//                self.window?.rootViewController = mainView
//            })
////            FirestoreDAO.getUserData(from: defaults.string(forKey: "userId")!) { (user1) in
////                settingsVC.user = user
////                self.window?.rootViewController = mainView
////            }
//        }
        
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let defaults = UserDefaults.standard
        let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        let loggedIn = defaults.bool(forKey:"loggedIn")
        if loggedIn {
            vc.getUserInfoForBackgroundTask(with: defaults.string(forKey: "userId")!)
            completionHandler(.newData)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BaitBit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

