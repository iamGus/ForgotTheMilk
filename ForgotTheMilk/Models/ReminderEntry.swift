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

public class Reminder: NSManagedObject {
    @NSManaged public var isActive: Bool
    @NSManaged public var location: NSData
    @NSManaged public var notes: NSString?
    @NSManaged public var timeStamp: NSDate
    @NSManaged public var title: NSString
    
    public override func awakeFromInsert() {
        
        super.awakeFromInsert()
        
        self.timeStamp = NSDate() // Set date for when entry created.
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
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    /// Use this method to create a new Reminder
    class func insertNewReminder(in context: NSManagedObjectContext, title: String, location: CLLocation, notes: String?) -> Reminder? {
        
        guard let reminder = NSEntityDescription.insertNewObject(forEntityName: Reminder.entityName, into: context) as? Reminder else { return nil }
        
        // store CLLocation
        let archivedLocation = NSKeyedArchiver.archivedData(withRootObject: location)
        reminder.setValue(archivedLocation, forKey: "location")
        
        reminder.title = title as NSString
        
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
        return String(describing: notes)
    }
    
    var timeStampDate: Date {
        return timeStamp as Date
    }
    
// Restrive location
    var retreiveLocation: CLLocation {
        //return NSKeyedUnarchiver.unarchiveObject(with: location as NSData) as CLLocation
        return CLLocation(coder: NSKeyedUnarchiver(forReadingWith: location as Data))!
    }
}
