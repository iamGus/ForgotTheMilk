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

protocol NotificationFromAppDelegate: class {
    func updateTableView()
    func updateContext()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext?
    
    weak var mainVCDelegate: NotificationFromAppDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        
        // Setup notifications authorization request
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Check if granted, if not then notify user
            if granted {
                print("Notification access granted")
            } else {
                print(error?.localizedDescription ?? "General Error: notification access not granted")
                self.window?.rootViewController?.showAlertApplicationSettings(forErorType: .turnOnNotifications)
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

// MARK: Location notification
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
    
    /// Restrive reminder from Core Data
    func getReminder(fromRegionIdentifier identifier: String) -> Reminder? {
        
        // Getting referance from the managed object context from masterListController which is the creator of the managedObjectContext
        let masterListController = UIApplication.shared.windows[0].rootViewController?.childViewControllers[0] as? MasterListController
        
        mainVCDelegate?.updateContext()
        
        guard let managedObjectContext = managedObjectContext else {
            print("getting managedObject return nil")
            return nil
        }
        
        
        guard let objectIDURL = URL(string: identifier), let objectID = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: objectIDURL) else {
                // could not get Object ID Error
                print("getting onject id from url to object nil error")
                return nil
        }
        
        do {
            var reminder = try managedObjectContext.existingObject(with: objectID) as? Reminder
            print("got reminder")
            
            // Set reminder to deactivated
            reminder?.isActive = true
            managedObjectContext.saveChanges()
            //managedObjectContext.saveChanges()
            mainVCDelegate?.updateTableView()
            return reminder
            
        } catch let error {
            print(error)
            return nil
        }
        
    }
    
    func handleEvent(forRegion region: CLRegion) {
        guard let reminder = getReminder(fromRegionIdentifier: region.identifier) else {
            // There was a problem access the notification data, infirm user
            notifyUser(title: "Reminder notifiction error", subtitle: "One of your notifications has just been triggered but error restriving notification data", notes: nil)
            return
        }
        
        notifyUser(title: reminder.titleString, subtitle: "Reminder has been triggered", notes: reminder.notesString)
       
        
    }
    
    func notifyUser(title: String, subtitle: String, notes: String?) {
        // show an alert if applocation is active
        if UIApplication.shared.applicationState == .active {
            window?.rootViewController?.showAlert(title: title, message: subtitle)
        } else {
            let notification = UNMutableNotificationContent()
            notification.title = title
            notification.subtitle = subtitle
            if let notes = notes {
                notification.body = notes
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
