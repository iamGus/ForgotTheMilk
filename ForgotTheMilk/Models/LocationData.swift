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

class LocationData {
    var locationCoordinates: CLLocation // Used to store in Reminder Core Data entity
    var locationPlacemark: String
    var locationRegion: CLCircularRegion?
    
    init(coordinates: CLLocationCoordinate2D, placemark: MKPlacemark, region: CLCircularRegion) {
        self.locationCoordinates = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.locationPlacemark = Utilities.parseAddress(from: placemark)
        self.locationRegion = region
    }
    
    init(coordinates: CLLocation, placemark: String) {
        self.locationCoordinates = coordinates
        self.locationPlacemark = placemark
    }
}

