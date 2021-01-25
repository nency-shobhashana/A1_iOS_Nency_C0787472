//
//  ViewController.swift
//  A1_iOS_Nency_C0787472
//
//  Created by Nency on 2021-01-25.
//  Copyright © 2021 Nency. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var selectedCities:[MKAnnotation] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        //MARK: - show user position
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        
        // MARK: - longPress gesture recognizer added
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Your location"
        annotation.coordinate = locations[0].coordinate
        
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - display annotation method with enable and disable region
    func displayAnnotation(annotation: MKPointAnnotation,
                           setRegion: Bool) {
        
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        if setRegion {
            mapView.setRegion(region, animated: true)
        }
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func onLongPress(gestureRecognizer: UIGestureRecognizer) {
        // discontinued long press
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
            return
        }
        else if gestureRecognizer.state != UIGestureRecognizer.State.began {
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            //MARK: - 4 tap remove all annotations(Markers) and overlays
            if selectedCities.count > 2 {
                btnDirection.isHidden = true
                mapView.removeAnnotations(selectedCities)
                mapView.removeOverlays(mapView.overlays)
                selectedCities = []
            }
            let position = selectedCities.count
            
            // add annotation for the coordinatet
            let annotation = MKPointAnnotation()
            annotation.title =  position == 0 ? "A" : position == 1 ? "B" : "C"
            annotation.coordinate = coordinate
            selectedCities.insert(annotation, at: position)
            
            displayAnnotation(annotation: annotation, setRegion: false)
            
            //MARK: - display line and area after 3rd tap
            if selectedCities.count == 3 {
                addPolygon()
                addPolyline()
                btnDirection.isHidden = false
            }
        }
    }
    
    //MARK: - polyline method
    func addPolyline() {
        var coordinates = selectedCities.map {$0.coordinate}
        coordinates.append(selectedCities[0].coordinate)
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    //MARK: - polygon method
    func addPolygon() {
        let coordinates = selectedCities.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    @IBOutlet weak var btnDirection: UIButton!
    //MARK: - Display routes
    @IBAction func drawDirection(_ sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = selectedCities.map {$0.coordinate}
        coordinates.append(selectedCities[0].coordinate)
        
        for index in 0...coordinates.count - 2{
            
            let sourcePlaceMark = MKPlacemark(coordinate: coordinates[index])
            let destinationPlaceMark = MKPlacemark(coordinate: coordinates[index + 1])
            
            // request a direction
            let directionRequest = MKDirections.Request()
            
            // define source and destination
            directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
            directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
            
            // transportation type
            directionRequest.transportType = .walking
            
            // calculate directions
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let directionResponse = response else {return}
                // create route
                let route = directionResponse.routes[0]
                // draw the polyline
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                
                // defining the bounding map rect
                let rect = route.polyline.boundingMapRect
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            }
        }
    }
}


extension ViewController: MKMapViewDelegate {
    
    //MARK: - render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 4
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            return rendrer
        }
        return MKOverlayRenderer()
    }
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
        
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let loc1 = CLLocation(latitude: view.annotation?.coordinate.latitude ?? 0, longitude: view.annotation?.coordinate.longitude ?? 0)
        let loc2 = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let position: String! = view.annotation?.title ?? ""
        let distance = loc1.distance(from: loc2)
        let alertController = UIAlertController(title: "Distance", message: "distance between your location and \(position ?? "") is \(String(format: "%.2f", distance)) meters.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
