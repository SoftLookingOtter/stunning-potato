//
//  LocationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {

    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var currentLocation: CLLocation?

    private var permissionContinuation: CheckedContinuation<Bool, Never>?

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() async -> Bool {
        let currentStatus = locationManager.authorizationStatus

        switch currentStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true

        case .denied, .restricted:
            return false

        case .notDetermined:
            return await withCheckedContinuation { continuation in
                permissionContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }

        @unknown default:
            return false
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        let isAuthorized = authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways

        if isAuthorized {
            startUpdatingLocation()
        }

        if authorizationStatus != .notDetermined {
            permissionContinuation?.resume(returning: isAuthorized)
            permissionContinuation = nil
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.last
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error: \(error.localizedDescription)")
    }
}
