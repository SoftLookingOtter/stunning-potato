//
//  MapViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//
//
//  Updated by Robin Eliasson 2026-05-21

import SwiftUI
import MapKit
import Combine

struct EchoPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

class MapViewModel: ObservableObject {
    @Published var locationService = LocationService()
    

    @Published var hiddenMemories: [EchoPin] = [
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4118, longitude: 15.6224)),
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4098, longitude: 15.6184)),
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4120, longitude: 15.6150))
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        locationService.$userLocation
            .sink { [weak self] newLocation in
                guard let location = newLocation else { return }
                print("Användaren är nu på: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
            .store(in: &cancellables)
    }
    
    func setupMap() {
        locationService.requestLocationPermission()
        locationService.startTracking()
    }
}
