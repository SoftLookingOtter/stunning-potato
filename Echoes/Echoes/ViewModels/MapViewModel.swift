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
    let category: MemoryCategory?

    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, category: MemoryCategory? = nil) {
        self.id = id
        self.coordinate = coordinate
        self.category = category
    }
}

class MapViewModel: ObservableObject {
    @Published var locationService = LocationService()
    private let notificationService = NotificationService()


    @Published var hiddenMemories: [EchoPin] = []

    @Published var distanceToNearestMemory: Double?
    @Published var memoriesWithinRangeCount: Int = 0
    @Published var activeRegionID: UUID?
    @Published var userCoordinate: CLLocationCoordinate2D?
    @Published var activeCategories: Set<MemoryCategory> = Set(MemoryCategory.allCases)

    var visibleMemories: [EchoPin] {
        hiddenMemories.filter { pin in
            // Pins utan kategori (testpins) visas alltid
            guard let category = pin.category else { return true }
            return activeCategories.contains(category)
        }
    }

    private static let proximityRadiusMeters: Double = 200
    private static let minMovementForUpdateMeters: Double = 5

    private var cancellables = Set<AnyCancellable>()
    private var pinLocationCache: [UUID: CLLocation] = [:]
    private var lastProximityLocation: CLLocation?

    #if DEBUG
    private static let testMemoryOffsetMeters: Double = 250
    private var hasSeededTestMemory = false
    #endif

    init() {
        locationService.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLocation in
                guard let self = self, let location = newLocation else { return }
                self.userCoordinate = location.coordinate
                self.updateProximity(for: location)
                #if DEBUG
                self.seedNearbyTestMemoryIfNeeded(near: location)
                #endif
            }
            .store(in: &cancellables)

        locationService.$activeRegionID
            .receive(on: DispatchQueue.main)
            .assign(to: &$activeRegionID)
    }

    #if DEBUG
    private func seedNearbyTestMemoryIfNeeded(near location: CLLocation) {
        guard !hasSeededTestMemory else { return }
        hasSeededTestMemory = true

        // 1° latitude ≈ 111 000 m, så vi får ca 250 m norrut från användaren
        let latitudeOffset = Self.testMemoryOffsetMeters / 111_000.0
        let testPin = EchoPin(coordinate: CLLocationCoordinate2D(
            latitude: location.coordinate.latitude + latitudeOffset,
            longitude: location.coordinate.longitude
        ))
        hiddenMemories.append(testPin)
        rebuildPinLocationCache()
        locationService.startMonitoringRegions(for: hiddenMemories)
    }
    #endif

    private func updateProximity(for userLocation: CLLocation) {
        // Throttla: hoppa ut om användaren rört sig mindre än 5m sen senaste uträkningen
        if let last = lastProximityLocation,
           userLocation.distance(from: last) < Self.minMovementForUpdateMeters {
            return
        }
        lastProximityLocation = userLocation

        let distances = visibleMemories.map { pin -> Double in
            let cached = pinLocationCache[pin.id]
                ?? CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            return userLocation.distance(from: cached)
        }

        distanceToNearestMemory = distances.min()
        memoriesWithinRangeCount = distances.filter { $0 <= Self.proximityRadiusMeters }.count
    }

    private func rebuildPinLocationCache() {
        pinLocationCache = Dictionary(uniqueKeysWithValues: hiddenMemories.map { pin in
            (pin.id, CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude))
        })
    }

    func toggleCategory(_ category: MemoryCategory) {
        if activeCategories.contains(category) {
            activeCategories.remove(category)
        } else {
            activeCategories.insert(category)
        }
        updateMonitoringForVisibleMemories()
        // Tvinga omräkning även om användaren inte rört sig
        lastProximityLocation = nil
        if let location = locationService.userLocation {
            updateProximity(for: location)
        }
    }

    private func updateMonitoringForVisibleMemories() {
        let visible = visibleMemories
        locationService.startMonitoringRegions(for: visible)
        notificationService.scheduleProximityNotifications(for: visible)
    }

    func setupMap() {
        locationService.requestLocationPermission()
        locationService.startTracking()
        Task {
            _ = await notificationService.requestNotificationPermission()
        }
    }

    func loadMemories(from context: ModelContext) {
        #if DEBUG
        seedLinkopingEchoesIfNeeded(in: context)
        #endif
        let descriptor = FetchDescriptor<EchoMemory>()
        let memories = (try? context.fetch(descriptor)) ?? []
        hiddenMemories = memories.map { memory in
            EchoPin(id: memory.id, coordinate: memory.coordinate, category: memory.category)
        }
        rebuildPinLocationCache()
        updateMonitoringForVisibleMemories()
    }

    #if DEBUG
    private func seedLinkopingEchoesIfNeeded(in context: ModelContext) {
        let allMemories = (try? context.fetch(FetchDescriptor<EchoMemory>())) ?? []
        let hasLinkopingEchoes = allMemories.contains { memory in
            abs(memory.latitude - 58.41) < 0.1 && abs(memory.longitude - 15.62) < 0.1
        }
        guard !hasLinkopingEchoes else { return }

        let testEchoes = [
            EchoMemory(
                title: "Stångåns viskningar",
                story: "Vid den här bänken vid Stångån satt jag och min mormor varje söndag och matade änderna.",
                category: .family,
                latitude: 58.4118,
                longitude: 15.6260
            ),
            EchoMemory(
                title: "Slottet i skuggorna",
                story: "På 1700-talet sägs det att en grå dam vandrade här om nätterna. Folk gick andra vägen.",
                category: .mysterious,
                latitude: 58.4087,
                longitude: 15.6190
            ),
            EchoMemory(
                title: "Stortorgets år",
                story: "Här stod tornet som föll 1812. Det berättas att marken fortfarande minns dånet.",
                category: .historical,
                latitude: 58.4109,
                longitude: 15.6214
            ),
            EchoMemory(
                title: "Sommaren -98",
                story: "Min första kärlek bodde precis här borta. Vi cyklade förbi varje dag bara för att se varandra.",
                category: .nostalgic,
                latitude: 58.4125,
                longitude: 15.6160
            )
        ]
        testEchoes.forEach { context.insert($0) }
        try? context.save()
    }
    #endif
}
