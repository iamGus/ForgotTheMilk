//
//  MapViewOnDetail.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 05/12/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import MapKit

extension DetailReminderController: MKMapViewDelegate {
    
    func setupMapView(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            mapView.removeOverlays(mapView.overlays)
            let circle = MKCircle(center: coordinate, radius: 50)
            mapView.add(circle)
        }
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
