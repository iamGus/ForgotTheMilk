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
        cell.detailTextLabel?.text = Utilities.parseAddress(from: result.placemark)
        
        return cell
    }
    
  
    
    // MARK: Helpers
    
    func object(at indexPath: IndexPath) -> MKMapItem {
        return data[indexPath.row]
    }
    
    func update(with data: [MKMapItem]) {
        self.data = data
    }

    
}
