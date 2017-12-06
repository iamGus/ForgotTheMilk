//
//  Location.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 01/12/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

enum NotifyOn: Int {
    case notifyOnEntry
    case notifyOnExit
}

class LocationData {
    var locationCoordinates: CLLocation // Used to store in Reminder Core Data entity
    var locationPlacemark: String
    var locationRegion: CLCircularRegion?
    var notifyOnEntry: NotifyOn = .notifyOnEntry
    var location2d: CLLocationCoordinate2D?
    var recurring: Recurring = .recurring
    
    // New entry init
    init(coordinates: CLLocationCoordinate2D, placemark: MKPlacemark, region: CLCircularRegion) {
        self.locationCoordinates = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.locationPlacemark = Utilities.parseAddress(from: placemark)
        self.locationRegion = region
        self.location2d = coordinates
        
    }
 
    // Exisiting entry init
    init(coordinates: CLLocation, placemark: String, recurring: Recurring, notifyOn: NotifyOn) {
        self.locationCoordinates = coordinates
        self.locationPlacemark = placemark
        self.location2d = CLLocationCoordinate2D(latitude: coordinates.coordinate.latitude, longitude: coordinates.coordinate.longitude)
        self.recurring = recurring
        self.notifyOnEntry = notifyOn
        self.locationRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinates.coordinate.latitude, longitude: coordinates.coordinate.longitude), radius: 50, identifier: "tempory")
        
        //can I create a location region here?
    }
    
   
}

