//
//  LocationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//
//  Updated by Robin Eliasson 2026-05-25

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?
    @Published var activeRegionID: UUID?

    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    private let maxMonitoredRegions = 20

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
        // Tyst — vi bryr oss inte om transienta GPS-fel
    }

    func startMonitoringRegions(for pins: [EchoPin]) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }

        // Stop existing monitoring to ensure we only track the current set of regions
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }

        let sortedPins: [EchoPin]
        if let userLocation = userLocation {
            sortedPins = pins.sorted { first, second in
                let firstLocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                let secondLocation = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
                return userLocation.distance(from: firstLocation) < userLocation.distance(from: secondLocation)
            }
        } else {
            sortedPins = pins
        }

        let regionsToMonitor = Array(sortedPins.prefix(maxMonitoredRegions))
        for pin in regionsToMonitor {
            let region = CLCircularRegion(center: pin.coordinate, radius: 200, identifier: pin.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
            // Hanterar iOS-quirk: didEnterRegion triggar inte om vi redan är inne i zonen vid start
            locationManager.requestState(for: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard state == .inside, let regionID = UUID(uuidString: region.identifier) else { return }
        DispatchQueue.main.async {
            self.activeRegionID = regionID
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let regionID = UUID(uuidString: region.identifier) else { return }
        DispatchQueue.main.async {
            self.activeRegionID = regionID
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let regionID = UUID(uuidString: region.identifier) else { return }
        DispatchQueue.main.async {
            if self.activeRegionID == regionID {
                self.activeRegionID = nil
            }
        }
    }
}
