//
//  LocationSearchController.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 29/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchDelegate: class {
    func saveSucceeded(locationData: LocationData)
}

class LocationSearchController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchViewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: self)
    }()
    
    let dataSource = LocationSearchDataSource()
    let client = LocalSearchAPI()
    weak var delegate: LocationSearchDelegate?
    
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        
        return isAuthorizedForLocation
    }
    
    var searchController: UISearchController!
    
    // Location properties
    var selectedPlacemarkData: LocationData?
    var currentLocation: CLLocationCoordinate2D? // Current location for mapview
    var segmentState: NotifyOn = .notifyOnEntry
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = dataSource

        
        // Setup search bar
        configureSearchController()
        
        // If not nil then current location data passed from detail VC
        if let selectedPlacemark = selectedPlacemarkData {
            
            if let coordinates = selectedPlacemark.location2d {
                updateExistingMapsLocation(with: coordinates)
            }
       
            // Check if recurring segmentState needs updated
            if selectedPlacemark.notifyOnEntry == .notifyOnEntry {
                segmentControl.selectedSegmentIndex = 0
                segmentState = .notifyOnEntry
            } else {
                segmentControl.selectedSegmentIndex = 1
                segmentState = .notifyOnExit
            }
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            print("Is authorised")// If already authorised then go ahead and request current location
            
            locationManager.requestLocation()
        } else {
            // Else if not authorised then request permission
            print("not authorised")
            requestLocationPermissions()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveLocation(_ sender: Any) {
        
        guard let selectedPlacemark = selectedPlacemarkData, (selectedPlacemark.locationRegion != nil) else {
            showAlert(title: "Cannot Save", message: "You have not selected any location, cannot save")
            return
        }
        
        // Set when to alert - arriving or departing
        switch segmentState {
        case .notifyOnEntry:
            selectedPlacemark.locationRegion?.notifyOnEntry = true
            selectedPlacemark.locationRegion?.notifyOnExit = false
            selectedPlacemark.notifyOnEntry = .notifyOnEntry
        case .notifyOnExit:
            selectedPlacemark.locationRegion?.notifyOnEntry = false
            selectedPlacemark.locationRegion?.notifyOnExit = true
            selectedPlacemark.notifyOnEntry = .notifyOnExit
        }
        print("placemark string: \(selectedPlacemark.locationPlacemark)")
        
        delegate?.saveSucceeded(locationData: selectedPlacemark)
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func segmentIndexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: segmentState = .notifyOnEntry
        case 1: segmentState = .notifyOnExit
        default: return
        }
    }
}

// MARK: Location Permissions / authorization
extension LocationSearchController: LocationPermissionsDelegate {
    
    // Request permission
    func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.setToWhenInUse {
            print("set to when in use")
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
        case .authorizedWhenInUse: showAlertApplicationSettings(forErorType: ShowAltertMessage.setToWhenInUse)
        default: showAlertApplicationSettings(forErorType: ShowAltertMessage.notSetToAlways)
            
        }
    }
}

// MARK: Location and maps settings
extension LocationSearchController: LocationManagerDelegate, MKMapViewDelegate {
    func obtainedCoordinates(_ location: CLLocation) {
        // If there is already location data from detail view then only update curent location property otherwise display current location on map
        if selectedPlacemarkData != nil {
            currentLocation = location.coordinate
        } else {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        currentLocation = location.coordinate
        
        }

    }
    
    func failedWithError(_ error: LocationError) {
        showAlert(title: "Location Error", message: "Sorry, unable to get your current location at this time!")
    }
    
    func updateMapsLocation(with placemark: MKPlacemark) {
        
        mapView.removeAnnotations(mapView.annotations) // remove any previous placemark on map
        let annotation = MKPointAnnotation()
        let coordinate = placemark.coordinate
        annotation.coordinate = coordinate
        mapView.zoomToUserLocation(coordinate: coordinate)
        
        // Generating a circular region
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: "tempory")
        
        mapView.removeOverlays(mapView.overlays)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)
        
        // Update class location properties
         selectedPlacemarkData = LocationData(coordinates: coordinate, placemark: placemark, region: region)
    }
    
    /// Passed by viewdidload for when user viewing existing reminder location
    func updateExistingMapsLocation(with coordinate: CLLocationCoordinate2D?) {
        
        if let coordinate = coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            mapView.removeOverlays(mapView.overlays)
            let circle = MKCircle(center: coordinate, radius: 50)
            mapView.add(circle)
        }
    }
    
    // Delegate to draw circle render on map
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

// Not using but delegate requires for it to be here, using textDidChange instead
extension LocationSearchController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    /// Setup search bar
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for places"
        searchController.searchBar.delegate = self
        searchViewContainer.addSubview(searchController.searchBar)
    }

    // When user begins to enter text into search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if isAuthorized {
            guard let currentLocation = currentLocation else {
                searchController.isActive = false
                showAlertApplicationSettings(forErorType: .couldNotGetCoordinates)
                return
            }
            
            client.search(withTerm: searchText, at: currentLocation) { (mapItems, error) in
                // If there is no internet connection this error notice is triggered, note though the apple map kit takes too long to bring back this error so would need to inhance this so error somes back quicker in a production app.
                if let searchError = error  {
                    // Needs more testing before activating the below
                    //self.searchController.isActive = false
                    //self.showAlert(title: "Error searching", message: "Unable to retrive search data, please check you ahve an internet conenction")
                    print("Error retrieving search data: \(searchError)")
                    return
                }
                self.dataSource.update(with: mapItems)
                self.tableview.reloadData()
            }
        } else {
            searchController.isActive = false
            showAlertApplicationSettings(forErorType: .locationsDefault)
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

