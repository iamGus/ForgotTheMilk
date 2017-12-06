//
//  LocationManager.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 29/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension Coordinate {
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}

enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
    case setToWhenInUse
}

enum AddLocationMonitoringError: Error {
    case notSupported
    case permissionNotAlways
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedCoordinates(_ location: CLLocation)
    func failedWithError(_ error: LocationError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    
    init(delegate: LocationManagerDelegate?, permissionsDelegate: LocationPermissionsDelegate?) {
        self.delegate = delegate
        self.permissionsDelegate = permissionsDelegate
        super.init()
        manager.delegate = self
       
        
    }
    
    
    
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways: return true
        default: return false
        }
    }
    
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined: manager.requestAlwaysAuthorization()
        case .denied, .restricted: throw LocationError.disallowedByUser
        case .authorizedWhenInUse: throw LocationError.setToWhenInUse
        case .authorizedAlways: return
        }
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        } else if authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // status is not determined so when status changes check:
        if status == .authorizedAlways {
            permissionsDelegate?.authorizationSucceeded()
        } else if status == .denied || status == .restricted || status == .authorizedWhenInUse {
            permissionsDelegate?.authorizationFailedWithStatus(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        // If using this switch statement in real world exspand to deal with other possible error cases
        switch error.code {
        case .locationUnknown, .network: delegate?.failedWithError(.unableToFindLocation)
        case .denied: delegate?.failedWithError(.disallowedByUser)
        default: return
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        
        // Send location coordinates to CurrentLocationController
        delegate?.obtainedCoordinates(location)
    }
    
    /// Adding location monitor for a Reminder
    func addMonitoringOfReminder(region: CLCircularRegion, objectID: NSManagedObjectID) throws {
        let passedRegion = region
        let region = CLCircularRegion(center: passedRegion.center, radius: passedRegion.radius, identifier: objectID.uriRepresentation().absoluteString)
        
        // If monitoring not available
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            throw AddLocationMonitoringError.notSupported
        }
        
        // If User not set location permission to always
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            throw AddLocationMonitoringError.permissionNotAlways
        }
        region.notifyOnEntry = passedRegion.notifyOnEntry
        print("onEntry: \(region.notifyOnEntry)")
        region.notifyOnExit = passedRegion.notifyOnExit
        print("onExi: \(region.notifyOnExit)")
        manager.startMonitoring(for: region)
    }
    
    static func removeMonitoringOfReminder(objectID: NSManagedObjectID) {
        let manager = CLLocationManager()
        for region in manager.monitoredRegions {
            print(region.identifier)
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == objectID.uriRepresentation().absoluteString else {
                print("could not remove monitoring")
                continue }
            manager.stopMonitoring(for: circularRegion)
            print("monitoring removed")
        }
    }
    
}
