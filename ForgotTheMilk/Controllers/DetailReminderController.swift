//
//  DetailReminderController.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//


import UIKit
import MapKit
import CoreData


class DetailReminderController: UIViewController {
    
    //Outlets
    @IBOutlet weak var shortTitleTextfield: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // Properties
    var managedObjectContext: NSManagedObjectContext!
    var currentReminder: Reminder? // If viewing current reminder master VC dependency injection
    var locationData: (Location: CLLocation?, Placemark:CLPlacemark?) // Store placemark data from location VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Keyboard display and remove
        
        // Observers for keyboard appearing and hiding
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // If user touches screen when keyboard shown
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        
        CheckIfNew()
    }
    
    /// Check if this is an existing reminder or a new reminder. If exisiting then populate fields:
    func CheckIfNew() {
        
        if let currentReminder = currentReminder {
            
            
        } else {
            // Must be a new entry
            // Set Date title to todays date
            
            
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
        // Check textfield not empty
        guard let titleText = shortTitleTextfield.text, titleText != "" else {
            print("fdfd")
            self.showAlert(title: "Alert", message: "You cannot save an entry without text, please first enter text")
            return
        }
        
        // Check if max characters have been entered in text field
        if titleText.count > 30 {
            self.showAlert(title: "Alert", message: "Your title  exceeds the 50 characters limit, please shorten")
            return
        }
        
        // If there is data in current Entry property then we are editing an existing entry
        if let currentReminder = currentReminder {
            
        } else { // Else it must be a new entry
            let tempLocation = CLLocation()
            guard let newReminder = Reminder.insertNewReminder(in: managedObjectContext, title: titleText, location: tempLocation, notes: notesTextView.text) else { return }
            
        }
        
        managedObjectContext.saveChanges()
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

// MARK: Additional keyboard setup
extension DetailReminderController {
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    // Used when user touches outside textfield to close keyboard
    @objc func dismissKeyboard() {
        shortTitleTextfield.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
}

