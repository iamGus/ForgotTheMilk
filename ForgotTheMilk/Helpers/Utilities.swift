//
//  Utilities.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 30/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import MapKit

extension MKMapView {
    func zoomToUserLocation(coordinate: CLLocationCoordinate2D) {
        let coordinate = coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        setRegion(region, animated: true)
    }
}


