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
    @IBOutlet weak var segmentControl: NSLayoutConstraint!
    
    
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
    
    // Location properties
    var locationCoordinates: CLLocation? // Get coordinates to pass to detail view
    var locationPlacemark: String? // Get placemark as string to pass to detail view
    var reminderRegion: CLCircularRegion? // Get region to pass back to detail view
    var currentLocation: CLLocationCoordinate2D? // Current location for mapview
    
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
    

    @IBAction func saveLocation(_ sender: Any) {
    }
    


}

//MARK: Location Permissions / authorization
extension LocationSearchController: LocationPermissionsDelegate {
    
    //Request permission
    func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.setToWhenInUse {
            print("set to when in use")
            //showAlertApplicationSettings(forErorType: LocationError.setToWhenInUse)
        } catch LocationError.disallowedByUser {
            // NOTE: This is where you would normaly have code bringing up alert to user that they need to change settings to allow the app to know location. But the didChangeAuthorization in locationManager is being triggered even when the authorization status has not changed meaning that the authroization failed with status deligate is being triggered which then brings up the correct UIAlert and thus why I have not put any code in here.
            print("disallowed by user")
            
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
        switch status {
        case .authorizedWhenInUse: showAlertApplicationSettings(forErorType: LocationError.setToWhenInUse)
        default: showAlertApplicationSettings(forErorType: LocationError.disallowedByUser)
            
        }
        
    }
    
    
    
}
//MARK: Location and maps setting
extension LocationSearchController: LocationManagerDelegate, MKMapViewDelegate {
    func obtainedCoordinates(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        currentLocation = location.coordinate
    }
    
    func failedWithError(_ error: LocationError) {
        showAlert(title: "Location Error", message: "Sorry, unable to get your current location at this time!")
    }
    
    func updateMapsLocation(with placemark: MKPlacemark) {
        //selectedPin = placemark
        mapView.annotations.flatMap { mapView.removeAnnotation($0) } // remove any previous placemark on map
        let annotation = MKPointAnnotation()
        let coordinate = placemark.coordinate
        annotation.coordinate = coordinate
        mapView.zoomToUserLocation(coordinate: coordinate)
        
        // Generating a circular region
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: "geofence")
        
        mapView.removeOverlays(mapView.overlays)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)
        
        // Update class location properties NOTE: Update this to be an init of a LocationData type
        let locationCoordinates = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.locationCoordinates = locationCoordinates
        self.locationPlacemark = dataSource.parseAddress(from: placemark)
        self.reminderRegion = region
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.2
        return circleRenderer
    }
 
    
}
// MARK: Search bar and table results

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
        
        if isAuthorized {
            client.search(withTerm: searchText, at: currentLocation!) { (mapItems, error) in
                // IF there is no internet connection this error notice is triggered, note though the apple map kit takes too long to bring back this error so would need to inhance this so error came abck quicker in a production app.
                if let searchError = error  {
                    //self.searchController.isActive = false
                    //self.showAlert(title: "Error searching", message: "Unable to retrive search data, please check you ahve an internet conenction")
                    print("Error restriving search data: \(error)")
                    return
                }
                self.dataSource.update(with: mapItems)
                self.tableview.reloadData()
            }
        } else {
            print("show alert")
            searchController.isActive = false
            showAlertApplicationSettings(forErorType: .unknownError)
        }
    
    }
    
    // Table cell clicked, update map
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deativates searh controller so that tableview cells are clickable
        if searchController.isActive == true {
            searchController.isActive = false
        }
        
        let cell = dataSource.object(at: indexPath).placemark
        updateMapsLocation(with: cell)
    }
    
}

