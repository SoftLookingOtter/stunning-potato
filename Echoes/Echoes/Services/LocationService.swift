//
//  LocationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//
//  Updated by Robin Eliasson 2026-05-20

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?

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

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func startUpdatingLocation() {
        startTracking()
    }

    func stopUpdatingLocation() {
        stopTracking()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        let isAuthorized = authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways

        if isAuthorized {
            startTracking()
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
        guard let latestLocation = locations.last else { return }

        DispatchQueue.main.async {
            self.userLocation = latestLocation
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error: \(error.localizedDescription)")
    }
}
