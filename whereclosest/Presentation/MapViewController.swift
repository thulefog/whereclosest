//
//  MapViewController.swift
//  whereclosest
//
//  Derived from SODA example:
//  https://github.com/socrata/soda-swift
//  Created by Hal Mueller on 6/2/17.
//  Copyright © 2017 Socrata. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let proximityUUID = UUID(uuidString: "EFF1456E-F28F-4EAC-8D04-738E73EACEDF")
    
    let beaconMajor : CLBeaconMajorValue = 100
    let beaconMinor : CLBeaconMinorValue = 1
    let beaconID = "com.aquavitdesigns.ignis.BeaconRegion"
    
    var locationManager:CLLocationManager!
    
    var data: [[String: Any]]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startReceivingLocationChanges()
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
                startScanning()
            }
        }
        
        update(withData: data, animated: true)
    }

    func startReceivingLocationChanges() {

        locationManager = CLLocationManager()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.

            locationManager.requestWhenInUseAuthorization( )
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("Updating location")
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        // manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current Location"
        mapView.addAnnotation(myAnnotation)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
    
    func startScanning() {
        let uuid = proximityUUID
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: beaconMajor, minor: beaconMinor, identifier: beaconID )
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func update(withData data: [[String: Any]]!, animated: Bool) {
        
        // Remember the data because we may not be able to display it yet
        self.data = data
        
        if (!isViewLoaded) {
            return
        }
        
        // Clear old annotations
        if mapView.annotations.count > 0 {
            let ex = mapView.annotations
            mapView.removeAnnotations(ex)
        }
        
        // Longitude and latitude limits
        var minLatitude : CLLocationDegrees = 90.0
        var maxLatitude : CLLocationDegrees = -90.0
        var minLongitude : CLLocationDegrees = 180.0
        var maxLongitude : CLLocationDegrees = -180.0

        // Create annotations for the data
        var anns : [MKAnnotation] = []
        for item in data {
            
            guard let lat = (item["latitude"] as? NSString)?.doubleValue,
                let lon = (item["longitude"] as? NSString)?.doubleValue else { continue }
            
            minLatitude = min(minLatitude, lat)
            maxLatitude = max(maxLatitude, lat)
            minLongitude = min(minLongitude, lon)
            maxLongitude = max(maxLongitude, lon)

            let a = MKPointAnnotation()
            a.title = item["location"] as? String ?? ""
            a.coordinate = CLLocationCoordinate2D (latitude: lat, longitude: lon)
            a.subtitle = item["neighboorhood"] as? String ?? item["hoursofoperation"] as? String ?? ""
            anns.append(a)
        }
        
        // Set the annotations and center the map
        if (anns.count > 0) {
            mapView.addAnnotations(anns)
            let span = MKCoordinateSpanMake(maxLatitude - minLatitude, maxLongitude - minLongitude)
            let center = CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude)/2.0, longitude: (maxLongitude + minLongitude)/2.0)
            let region = MKCoordinateRegionMake(center, span)

            mapView.setRegion(region, animated: animated)
        }
    }
    
    func mapView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "wc")
        annotationView!.image = pinImage
        
        return annotationView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print( "Beacon range: unknown" )
                
            case .far:
                print( "Beacon range: far" )

            case .near:
                print( "Beacon range: near" )

            case .immediate:
                print( "Beacon range: immediate" )
            }
        }
    }
}

