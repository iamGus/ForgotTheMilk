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
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchViewContainer: UIView!
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: self)
    }()
    
    let dataSource = LocationSearchDataSource()
    let client = LocalSearchAPI()
    
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        
        return isAuthorizedForLocation
    }
    
    var searchController: UISearchController!
    
    var tempLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = dataSource
        
        // Setup search bar
        configureSearchController()
        
        
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
    

    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive == true {
           searchController.isActive = false
        }
        
        let cell = dataSource.object(at: indexPath).placemark
        updateMapsLocation(with: cell)
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
//MARK: Location and maps
extension LocationSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        tempLocation = location.coordinate
    }
    
    func failedWithError(_ error: LocationError) {
        showAlert(title: "Location Error", message: "Sorry, unable to get your current location at this time!")
    }
    
    func updateMapsLocation(with placemark: MKPlacemark) {
        //selectedPin = placemark
        mapView.annotations.flatMap { mapView.removeAnnotation($0) } // remove any previous placemark on map
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}
// Search

extension LocationSearchController: UISearchResultsUpdating, UISearchBarDelegate {
    
    /// Setup search bar
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for places"
        searchController.searchBar.delegate = self
        searchViewContainer.addSubview(searchController.searchBar)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updating")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        client.search(withTerm: searchText, at: tempLocation!) { (mapItems, error) in
            if let searchError = error  {
                print(searchError)
                return
            }
            self.dataSource.update(with: mapItems)
            self.tableview.reloadData()
        }
    }
    
    
}

