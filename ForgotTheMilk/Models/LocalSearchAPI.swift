//
//  LocalSearchAPI.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 29/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import MapKit

class LocalSearchAPI {
    
    
    func search(withTerm term: String, at coordinate: CLLocationCoordinate2D, completion: @escaping ([MKMapItem], Error?) -> Void) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = term
        request.region.center = coordinate
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                return completion([], error)
            }
            return completion(response.mapItems, nil)
        }
    }
    
}


