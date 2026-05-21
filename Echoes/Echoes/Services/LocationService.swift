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

// NSObject behövs för att kunna samarbeta med Apples äldre CLLocationManager
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // Den inbyggda managern som sköter GPS-hårdvaran
    private let locationManager = CLLocationManager()
    
    // Denna variabel publicerar användarens nuvarande position så att vår ViewModel kan se den
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Högsta möjliga precision
    }
    
    // Funktion för att trigga rutan: "Vill du tillåta att appen använder din plats?"
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Funktion för att starta GPS-spårningen
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    // DELEGATE-METOD: Denna körs automatiskt varje gång telefonen känner att man flyttat på sig
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        // Uppdaterar vår publicerade variabel på huvudtråden (UI-tråden)
        DispatchQueue.main.async {
            self.userLocation = latestLocation
        }
    }
}
