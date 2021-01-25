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
        
        let userLocation = locations[0]
        
        let annotation = MKPointAnnotation()
        annotation.title = "Your location"
        annotation.coordinate = userLocation.coordinate
        
        displayAnnotation(annotation: annotation, setRegion: true)
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
}


extension ViewController: MKMapViewDelegate {
    
    //MARK: - render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            return rendrer
        }
        return MKOverlayRenderer()
    }
}
