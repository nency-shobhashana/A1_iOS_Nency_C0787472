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
        
        // MARK: - double tap gesture recognizer added for remove pin
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Your location"
        annotation.coordinate = locations[0].coordinate
        
        //MARK: - zooming area
        let latDelta: CLLocationDegrees = 1.3
        let lngDelta: CLLocationDegrees = 1.3
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - display annotation method with enable and disable region
    func displayAnnotation(annotation: MKPointAnnotation,
                           setRegion: Bool) {
        
        let latDelta: CLLocationDegrees = 1.3
        let lngDelta: CLLocationDegrees = 1.3
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        if setRegion {
            mapView.setRegion(region, animated: true)
        }
        // added annotaion and circle overlay to detact nearby tap event
        mapView.addAnnotation(annotation)
        mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 7000))
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
            let mappoint = MKMapPoint(coordinate)
            
            //MARK: - detact if tap is inside in any overlay then do nothing
            for overlay in self.mapView.overlays {
                if let circle = overlay as? MKCircle {
                    
                    let centerMP = MKMapPoint(circle.coordinate)
                    let distance = mappoint.distance(to: centerMP)
                    
                    if distance <= circle.radius {
                        //"Tap was inside this circle of already added annotation(marker)"
                        return
                    }
                    continue
                }
            }
            
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
    //MARK: - double tap recognized, drop if it is near by marker
    @objc func dropPin(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let mappoint = MKMapPoint(coordinate)
        
        // find overlay in which double tap happen
        for overlay in self.mapView.overlays {
            if let circle = overlay as? MKCircle {
                
                let centerMP = MKMapPoint(circle.coordinate)
                let distance = mappoint.distance(to: centerMP)
                
                if distance <= circle.radius {
                    // find annotation for which double tap happen
                    for i in 0...selectedCities.count - 1 {
                        if  MKMapPoint(selectedCities[i].coordinate).distance(to: centerMP) <= 600 {
                            if selectedCities.count == 3 {
                                mapView.removeOverlays(mapView.overlays.filter({ (mKOverlay) -> Bool in
                                    !(mKOverlay is MKCircle)
                                }))
                            }
                            mapView.removeOverlay(overlay)
                            mapView.removeAnnotation(selectedCities[i])
                            selectedCities.remove(at: i)
                            return
                        }
                    }
                    
                }
                continue
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
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.white.withAlphaComponent(0)
            return rendrer
        } else if overlay is MKPolyline {
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
