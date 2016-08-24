//
//  LocationManager.swift
//  HitupMe
//
//  Created by Arthur Shir on 10/24/15.
//  Copyright © 2015 HitupDev. All rights reserved.
//

import UIKit
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    var coreLocMan: CLLocationManager
    var wait: Bool
    var lat: Double
    var lng: Double
    var coords: CLLocationCoordinate2D
    
    override init() {
        
        // Initialize Locaiton Manager with Accuracy
        coreLocMan = CLLocationManager()
        coreLocMan.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Get Stored Lat/Lng if saved
        let defaults = NSUserDefaults.standardUserDefaults()
        let latitude = defaults.objectForKey("latitude") as? Double
        let longitude = defaults.objectForKey("longitude") as? Double
        if (latitude != nil && longitude != nil) {
            lat = latitude!
            lng = longitude!
        } else {
            // If there is no saved location, set location as Fremont, CA
            lat = 37.5293657
            lng = -122.0689915
        }
        
        // Set Coordinates
        coords = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        wait = false
        
        super.init()
        coreLocMan.delegate = self
        
    }
    
    func startUpdatingLocation(){
        coreLocMan.startUpdatingLocation()
    }
    
    func waitForLocation(completion:((success:Bool) -> Void)) {
        wait = true
        startUpdatingLocation()
        //while (wait == true ) {
            completion(success: true)
        //}
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        lat = newLocation.coordinate.latitude
        lng = newLocation.coordinate.longitude
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(lat, forKey: "latitude")
        defaults.setDouble(lng, forKey: "longitude")
        
        coreLocMan.stopUpdatingLocation()
        print(lat, lng)
        
        wait = false
    }
    
    
}
