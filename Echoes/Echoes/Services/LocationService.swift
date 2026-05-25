//
//  LocationService.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//
//  Updated by Robin Eliasson 2026-05-20

import Foundation
import CoreLocation
import Combine

// NSObject needs for  Apples older CLLocationManager
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // GPS manager
    private let locationManager = CLLocationManager()
    
    // shows the users position so we can use it in our MapView
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Högsta möjliga precision
    }
    
    // is there permission to use location services? If not, ask for it
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // start tracking the users location
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    // automatically called when the location manager gets a new location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        // updates the userLocation on the main thread since it's a @Published property that the UI listens to
        DispatchQueue.main.async {
            self.userLocation = latestLocation
        }
    }
}
