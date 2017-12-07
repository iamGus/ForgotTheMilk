//
//  Reminder.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import CoreData
import UIKit
import CoreLocation

enum Recurring: Int {
    case recurring
    case onceonly
}

public class Reminder: NSManagedObject {
    @NSManaged public var isActive: Bool
    @NSManaged public var location: NSData
    @NSManaged public var notes: NSString?
    @NSManaged public var timeStamp: NSDate
    @NSManaged public var title: NSString
    @NSManaged public var placeMark: NSString
    @NSManaged public var recurringAmount: Int16
    @NSManaged public var notify: Int16
    
    public override func awakeFromInsert() {
        
        super.awakeFromInsert()
        
        self.timeStamp = NSDate() // Set date for when entry created.
        self.recurringAmount = 0
        self.notify = 0
    }
}

extension Reminder {
    
    /// String name on Reminder class
    static var entityName: String {
        return String(describing: Reminder.self)
    }
    
    /// For section sorting, Active or past reminder heading
    @objc var section: String? {
        return isActive ? "Active Reminders" : "Past Reminders"
    }
    
    /// Sort all reminders by dateStamp
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "isActive", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor, sortDescriptor2]
        return request
    }
    
    /// Use this method to create a new Reminder
    class func insertNewReminder(in context: NSManagedObjectContext, title: String, location: CLLocation, notes: String?, placemark: String, recurring: Recurring, notifyOn: NotifyOn) -> Reminder? {
        
        guard let reminder = NSEntityDescription.insertNewObject(forEntityName: Reminder.entityName, into: context) as? Reminder else { return nil }
        
        // store CLLocation
        let archivedLocation = NSKeyedArchiver.archivedData(withRootObject: location)
        reminder.setValue(archivedLocation, forKey: "location")
        
        reminder.title = title as NSString
        reminder.placeMark = placemark as NSString
        reminder.recurringStatus = recurring
        reminder.notifyOnStatus = notifyOn
        
        if let notes = notes {
            reminder.notes = notes as NSString
        }
        
        return reminder
        
    }
    
    class func updateReminder(currentReminder: Reminder, title: String, location: CLLocation, notes: String?, placemark: String, recurring: Recurring, notifyOn: NotifyOn) -> Reminder {
        let reminder = currentReminder
        reminder.title = title as NSString
        reminder.placeMark = placemark as NSString
        reminder.recurringStatus = recurring
        reminder.notifyOnStatus = notifyOn
        
        // store CLLocation
        let archivedLocation = NSKeyedArchiver.archivedData(withRootObject: location)
        reminder.setValue(archivedLocation, forKey: "location")
        print("data description: \(reminder.location.description)")
        
        if let notes = notes {
            reminder.notes = notes as NSString
        }
        
        return reminder
    }
    
}
// Make swift types of managed objects
extension Reminder {
    var titleString: String {
        return String(title)
    }
    
    var notesString: String? {
        guard let notes = notes else { return nil }
        return String(notes)
    }
    
    var placeMarkString: String {
        return String(placeMark)
    }
    
    var timeStampDate: Date {
        return timeStamp as Date
    }
    
// Restrive location
    var retreiveLocation: CLLocation {
        //return NSKeyedUnarchiver.unarchiveObject(with: location as NSData) as CLLocation
        
        let data = NSKeyedUnarchiver.unarchiveObject(with: self.location as Data) as! CLLocation
        return data
        
    }
    
    var recurringStatus: Recurring {
        get {
            return Recurring(rawValue: Int(self.recurringAmount))!
        }
        set {
            self.recurringAmount = Int16(newValue.rawValue)
        }
    }
    
    var notifyOnStatus: NotifyOn {
        get {
            return NotifyOn(rawValue: Int(self.notify))!
        }
        set {
            self.notify = Int16(newValue.rawValue)
        }
    }
}


 

