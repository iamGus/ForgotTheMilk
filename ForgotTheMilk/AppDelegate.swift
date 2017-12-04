//
//  AppDelegate.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        
        // Setup notifications authorization request
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization
            if granted {
                print("Notification access granted")
            } else {
                print(error?.localizedDescription ?? "General Error: notification access not granted")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
      
        
        return true
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
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("DidEnter: \(region.identifier)")
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("DidExit \(region.identifier)")
            handleEvent(forRegion: region)
        }
    }
    
    func getReminder(fromRegionIdentifier identifier: String) -> Reminder? {
        
        // Getting the managed object conetcxt from masterListController which is teh creatrp of the managedobjectcontext
        let masterListController = UIApplication.shared.windows[0].rootViewController?.childViewControllers[0] as? MasterListController
        guard let managedObjectContext = masterListController?.managedObjectContext else {
            print("getting managedObject return nil")
            return nil // ERROR HANDLING
        }
        
        
        guard let objectIDURL = URL(string: identifier), let objectID = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectIDURL) else {
                // could not get Object ID Error
                print("getting onject id from url to object nil error")
                return nil
        }
        
        do {
            var reminder = try managedObjectContext.existingObject(with: objectID) as? Reminder
            print("got reminder")
            return reminder
            
        } catch let error {
            print(error)
            return nil
        }
        
    }
    
    func handleEvent(forRegion region: CLRegion) {
        guard let reminder = getReminder(fromRegionIdentifier: region.identifier) else {
            return // NOTE DO I NEED BETTER ERROR HANDLING
            print("reminder returned nil")
        }
        
        print(reminder.isActive)
        
        // show an alert if applocation is active
        if UIApplication.shared.applicationState == .active {
            window?.rootViewController?.showAlert(title: "Reminder has been triggered", message: "\(reminder.titleString)")
        } else {
            let notification = UNMutableNotificationContent()
            notification.title = reminder.titleString
            notification.subtitle = "Your reminder has been triggered"
            if reminder.notesString != nil {
                notification.body = reminder.notesString!
            }
            notification.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier: "Notification", content: notification, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print(error)
                }
            })
        }
    }
    
 
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Response received for \(response.actionIdentifier)")
        completionHandler()
    }
}
