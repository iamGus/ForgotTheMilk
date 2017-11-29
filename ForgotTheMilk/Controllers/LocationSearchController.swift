//
//  LocationSearchController.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 29/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: self)
    }()
    
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        
        return isAuthorizedForLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            print("Is authorized")// If already authorised then go ahead and request current location
            locationManager.requestLocation()
        } else {
            // Else if not authorised then request permission
            print("not authorized")
            requestLocationPermissions()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationSearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    
}

// Permissions
extension LocationSearchController: LocationPermissionsDelegate {
    
    //Request permission
    func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            // NOTE: This is where you would normaly have code bringing up alert to user that they need to change settings to allow the app to know location. But the didChangeAuthorization in locationManager is being triggered even when the authorization status has not changed meaning that the authroization failed with status deligate is being triggered which then brings up the correct UIAlert and thus why I have not put any code in here.
            
        } catch let error {
            print("Location Authorization Error: \(error.localizedDescription)")
        }
    }
    
    
    func authorizationSucceeded() {
        // location manager permission returns success so go ahead and now request location
        locationManager.requestLocation()
    }
    
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus) {
        // Meaning authorization is denied so ask user to allow permissions in settings
        let alertController = UIAlertController(title: "Permission Request", message: "Location permission is currently not allowed, please change in settings so app can find your location", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {
            UIAlertAction in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: { (success) in
                                                print("Open \(UIApplicationOpenSettingsURLString): \(success)")
                    })
                } else {
                    let success = UIApplication.shared.openURL(url)
                    print("Open \(UIApplicationOpenSettingsURLString): \(success)")
                }
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension LocationSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ location: CLLocation) {
        let coordinate = Coordinate(location: location)
        print(coordinate.latitude)
    }
    
    func failedWithError(_ error: LocationError) {
        showAlert(title: "Location Error", message: "Sorry, unable to get your current location at this time!")
    }
    
    
}
