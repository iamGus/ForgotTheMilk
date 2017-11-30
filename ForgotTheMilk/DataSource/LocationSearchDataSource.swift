//
//  LocalSearchDataSource.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 29/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MapKit

class LocationSearchDataSource: NSObject, UITableViewDataSource {
    
    private var data = [MKMapItem]()
    
    override init() {
        super.init()
    }
    
    // MARK: Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = object(at: indexPath)
        
        cell.textLabel?.text = result.name
        cell.detailTextLabel?.text = parseAddress(from: result.placemark)
        
        return cell
    }
    
  
    
    // MARK: Helpers
    
    func object(at indexPath: IndexPath) -> MKMapItem {
        return data[indexPath.row]
    }
    
    func update(with data: [MKMapItem]) {
        self.data = data
    }
    
    func parseAddress(from placemark: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? ""
        )
        return addressLine
    }
    
}
