//
//  MapViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//
//
//  Updated by Robin Eliasson 2026-05-25

import SwiftUI
import MapKit
import Combine
import SwiftData

struct EchoPin: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D

    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.coordinate = coordinate
    }
}

class MapViewModel: ObservableObject {
    @Published var locationService = LocationService()
    private let notificationService = NotificationService()


    @Published var hiddenMemories: [EchoPin] = [
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4118, longitude: 15.6224)),
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4098, longitude: 15.6184)),
        EchoPin(coordinate: CLLocationCoordinate2D(latitude: 58.4120, longitude: 15.6150))
    ]

    @Published var distanceToNearestMemory: Double?
    @Published var memoriesWithinRangeCount: Int = 0

    private static let proximityRadiusMeters: Double = 200

    private var cancellables = Set<AnyCancellable>()

    init() {
        locationService.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLocation in
                guard let self = self, let location = newLocation else { return }
                print("Användaren är nu på: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                self.updateProximity(for: location)
            }
            .store(in: &cancellables)
    }

    private func updateProximity(for userLocation: CLLocation) {
        let distances = hiddenMemories.map { pin -> Double in
            let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            return userLocation.distance(from: pinLocation)
        }

        distanceToNearestMemory = distances.min()
        memoriesWithinRangeCount = distances.filter { $0 <= Self.proximityRadiusMeters }.count
    }

    func setupMap() {
        locationService.requestLocationPermission()
        locationService.startTracking()
        Task {
            _ = await notificationService.requestNotificationPermission()
        }
    }

    func loadMemories(from context: ModelContext) {
        let descriptor = FetchDescriptor<EchoMemory>()
        let memories = (try? context.fetch(descriptor)) ?? []
        hiddenMemories = memories.map { memory in
            EchoPin(id: memory.id, coordinate: memory.coordinate)
        }
        locationService.startMonitoringRegions(for: hiddenMemories)
        notificationService.scheduleProximityNotifications(for: hiddenMemories)
    }
}
