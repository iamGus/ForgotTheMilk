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
import CoreLocation


class DetailReminderController: UIViewController, LocationSearchDelegate {
    
    //Outlets
    @IBOutlet weak var shortTitleTextfield: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recurringSegmentState: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // Properties
    var managedObjectContext: NSManagedObjectContext!
    var currentReminder: Reminder? // If viewing current reminder master VC dependency injection
    var locationManager = LocationManager(delegate: nil, permissionsDelegate: nil)
    var segmentState: Recurring {
        if recurringSegmentState.selectedSegmentIndex == 0 {
            return .recurring
        } else {
            return .onceonly
        }
    }
    
    // Store Region and location data
    var remindersLocationData: LocationData? // Passed from LocationsSearchController
    
        // Check if notes field has text
        var notesHasText: String? {
            if notesTextView.text == "Enter extra notes here" {
                return nil
            } else if notesTextView == nil {
                return nil
            } else {
                return notesTextView.text
            }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTextView.textColor = UIColor.gray
        notesTextView.text = "Enter extra notes here"
        notesTextView.delegate = self
        
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
        
        // If Current viewing current reminder
        if let currentReminder = currentReminder {
            
            
            shortTitleTextfield.text = currentReminder.titleString
            locationButton.setTitle(currentReminder.placeMarkString, for: .normal)
            if let textView = currentReminder.notesString {
                notesTextView.text = textView
            }
            
            // initialise location data
            remindersLocationData = LocationData(coordinates: currentReminder.retreiveLocation, placemark: currentReminder.placeMarkString, recurring: currentReminder.recurringStatus, notifyOn: currentReminder.notifyOnStatus)
            
            
            // Check if reminder is currently deactivated, if it is then disable save button. To add addtional feature later on to be able to re-save (which would reactivate) a deactivated reminder
            if currentReminder.isActive == false {
                saveButton.isEnabled = false
            }
            
            // Check if recurring segmentState needs updated
            if let recurring = remindersLocationData?.recurring {
                if recurring == .recurring {
                    recurringSegmentState.selectedSegmentIndex = 0
                } else {
                    recurringSegmentState.selectedSegmentIndex = 1
                }
            }
            
            
            // Updating mapview
            setupMapView(coordinate: remindersLocationData?.location2d)
            
            
        } else {
            // Must be a new reminder
            
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
        // Check textfield not empty
        guard let titleText = shortTitleTextfield.text, titleText != "" else {
        
            self.showAlert(title: "Alert", message: "You cannot save an entry without text, please first enter text")
            return
        }
        
        // Check if max characters have been entered in text field
        if titleText.count > 30 {
            self.showAlert(title: "Alert", message: "Your title  exceeds the 50 characters limit, please shorten")
            return
        }
        
        // If there is data in current Entry property then we are editing an existing entry
        if currentReminder != nil {
            guard let locationData = remindersLocationData else {
                // No location data, you must first choose a location before you can save
                showAlert(title: "Cannot save reminder", message: "You have not chosen a location yet, please first choose a location before saving")
                return
            }
            
            // Update reminder entry
            let updateReminder: Reminder = Reminder.updateReminder(currentReminder: currentReminder!, title: titleText, location: locationData.locationCoordinates, notes: notesHasText, placemark: locationData.locationPlacemark, recurring: segmentState, notifyOn: locationData.notifyOnEntry)
            
            // If there is data in region update location reminder
            if let locationRegion = locationData.locationRegion {
                tryAddMonitoring(region: locationRegion, objectID: updateReminder.objectID)
            }
            
            // If the reminder is deactivated, set to activated
            if updateReminder.isActive == false {
                updateReminder.isActive = true
            }
            
            currentReminder = updateReminder
    
            managedObjectContext.saveChanges()
            
        } else { // Else it must be a new entry
            guard let locationData = remindersLocationData, let locationRegion = locationData.locationRegion else {
                // No location data, you must first choose a location before you can save
                showAlert(title: "Cannot save reminder", message: "You have not chosen a location yet, please first choose a location before saving")
                return
            }
            
            
            guard let newReminder = Reminder.insertNewReminder(in: managedObjectContext, title: titleText, location: locationData.locationCoordinates, notes: notesHasText, placemark: locationData.locationPlacemark, recurring: segmentState, notifyOn: locationData.notifyOnEntry) else {
                
                    showAlert(title: "Save Error", message: "Sorry could not save reminder, please try again")
                    return
                }
            
            // Need to save changes to manged object now before add monitoring so can get correct saved ID
            managedObjectContext.saveChanges()
            
            // Set monitoring of location
            tryAddMonitoring(region: locationRegion, objectID: newReminder.objectID)
            
            
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func recurringStateAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: remindersLocationData?.recurring = .recurring
        case 1: remindersLocationData?.recurring = .onceonly
        default: return
        }
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocation" {
            let locationSearchController = segue.destination as! LocationSearchController
            locationSearchController.delegate = self
            
            // If the user is viewing a existing entry or if the user is on a new entry but they have already chosen a location but deciding to go back and edit / change it
            
            if let locationData = remindersLocationData {
                
                locationSearchController.selectedPlacemarkData = locationData
            }
        }
    }
    
    // Once get locationData back from Location VC update location data
    func saveSucceeded(locationData: LocationData) {
        print("Save succeeded hit")
        remindersLocationData = locationData
        setupMapView(coordinate: remindersLocationData?.location2d)
        
        locationButton.setTitle(locationData.locationPlacemark, for: .normal)
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

// Setting placeholder feature into notes textview
extension DetailReminderController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray && textView.text == "Enter extra notes here" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter extra notes here"
            textView.textColor = UIColor.gray
        }
    }
}

// Location update Helper

extension DetailReminderController {
    func tryAddMonitoring(region: CLCircularRegion, objectID: NSManagedObjectID) {
        do {
            try locationManager.addMonitoringOfReminder(region: region, objectID: objectID)
            print(objectID.description)
        } catch AddLocationMonitoringError.notSupported {
            showAlert(title: "Save Error", message: "Sorry but your device does not support location monitoring, your reminder has been saved but you will not be alerted when notification vent has been triggered")
        } catch AddLocationMonitoringError.permissionNotAlways {
            showAlertApplicationSettings(forErorType: .setToWhenInUse)
        } catch {
            print("Adding region unknown error")
        }
    }
    
}
