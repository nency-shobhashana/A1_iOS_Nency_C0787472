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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //MARK: - show user current position
        // assign the delegate property of the location manager to be this calss
        locationManager.delegate = self
        
        //we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //request for the permission to acess the location
        locationManager.requestWhenInUseAuthorization()
        
        //start updating the location
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //        print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        displayLocation(latitude: latitude, longitude: longitude, title: "you are here", subtitle: "")
    }
    
    // MARK: - display user location
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        //2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        // 3rd step is to define location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //4th step to define region
        let region = MKCoordinateRegion(center: location, span: span)
        
        //5th step is to det the region for the map
        mapView.setRegion(region, animated: true)
        
        //6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        
    }

}

extension ViewController: MKMapViewDelegate {
    
}

