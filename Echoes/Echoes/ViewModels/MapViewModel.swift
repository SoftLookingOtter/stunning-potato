//
//  MapViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//
//
//  Updated by Robin Eliasson 2026-06-11

import SwiftUI
import MapKit
import Combine
import SwiftData

struct EchoPin: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let category: MemoryCategory?
    let title: String?
    let story: String?
    let date: Date?
    let imageName: String?

    init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        category: MemoryCategory? = nil,
        title: String? = nil,
        story: String? = nil,
        date: Date? = nil,
        imageName: String? = nil
    ) {
        self.id = id
        self.coordinate = coordinate
        self.category = category
        self.title = title
        self.story = story
        self.date = date
        self.imageName = imageName
    }
}

class MapViewModel: ObservableObject {
    @Published var locationService = LocationService()
    private let notificationService = NotificationService()

    @Published var hiddenMemories: [EchoPin] = []

    @Published var distanceToNearestMemory: Double?
    @Published var memoriesWithinRangeCount: Int = 0
    @Published var activeRegionID: UUID?
    @Published var revealedPinIDs: Set<UUID> = []
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

    private var cancellables = Set<AnyCancellable>()

    init() {
        locationService.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLocation in
                guard let self = self, let location = newLocation else { return }
                self.userCoordinate = location.coordinate
                self.updateProximity(for: location)
            }
            .store(in: &cancellables)

        locationService.$activeRegionID
            .receive(on: DispatchQueue.main)
            .assign(to: &$activeRegionID)
    }

    #if DEBUG
    /// Hårdkodade testdata vid Fridtunagatan i Linköping — en av varje kategori.
    func seedFridtunagatanDemoEchoesIfNeeded(in context: ModelContext) {
        let fridtunagatan = CLLocationCoordinate2D(latitude: 58.4154, longitude: 15.6175)
        let degPerMeterLat = 1.0 / 111_000.0
        let degPerMeterLon = 1.0 / (111_000.0 * cos(fridtunagatan.latitude * .pi / 180))

        let demoEchoes = [
            EchoMemory(
                title: "Gamla cykelturen",
                story: "Här cyklade jag som barn varje morgon. Lukten av nytvättad asfalt hänger fortfarande kvar.",
                category: .nostalgic,
                latitude: fridtunagatan.latitude + 180 * degPerMeterLat,
                longitude: fridtunagatan.longitude
            ),
            EchoMemory(
                title: "Söndagsfika hos farmor",
                story: "Vi samlades alltid här på söndagar. Hennes kanelbullar var de bästa i världen.",
                category: .family,
                latitude: fridtunagatan.latitude,
                longitude: fridtunagatan.longitude + 180 * degPerMeterLon
            ),
            EchoMemory(
                title: "Smedjan vid hörnet",
                story: "Här stod en gammal smedja på 1800-talet. Folk minns ljudet av hammaren än idag.",
                category: .historical,
                latitude: fridtunagatan.latitude - 180 * degPerMeterLat,
                longitude: fridtunagatan.longitude
            ),
            EchoMemory(
                title: "Den vita gestalten",
                story: "På nätterna sägs det att en vit gestalt vandrar här. Ingen vet vem hon var.",
                category: .mysterious,
                latitude: fridtunagatan.latitude,
                longitude: fridtunagatan.longitude - 180 * degPerMeterLon
            )
        ]

        let demoTitles = Set(demoEchoes.map { $0.title })
        let allMemories = (try? context.fetch(FetchDescriptor<EchoMemory>())) ?? []
        let existingDemos = allMemories.filter { demoTitles.contains($0.title) }

        let fridtunaCLLocation = CLLocation(latitude: fridtunagatan.latitude, longitude: fridtunagatan.longitude)
        let allUpToDate = existingDemos.count == demoEchoes.count && existingDemos.allSatisfy { memory in
            let memoryLocation = CLLocation(latitude: memory.latitude, longitude: memory.longitude)
            return fridtunaCLLocation.distance(from: memoryLocation) < 500
        }
        if allUpToDate { return }

        existingDemos.forEach { context.delete($0) }
        demoEchoes.forEach { context.insert($0) }
        try? context.save()
        loadMemories(from: context)
    }

    /// Hårdkodade testdata vid Robins arbetsposition i Mjärdevi — en av varje kategori.
    /// Tätt kluster runt 58.393007, 15.560433 så man kan nå alla med några stegs promenad.
    func seedTeknikringenDemoEchoesIfNeeded(in context: ModelContext) {
        let workPosition = CLLocationCoordinate2D(latitude: 58.393007, longitude: 15.560433)
        let degPerMeterLat = 1.0 / 111_000.0
        let degPerMeterLon = 1.0 / (111_000.0 * cos(workPosition.latitude * .pi / 180))

        let demoEchoes = [
            EchoMemory(
                title: "Forskarens dröm",
                story: "Här satt en ung doktorand och skissade på framtiden vid ett fönster med utsikt över parken.",
                category: .nostalgic,
                latitude: workPosition.latitude + 15 * degPerMeterLat,
                longitude: workPosition.longitude
            ),
            EchoMemory(
                title: "Lunchen med pappa",
                story: "Pappa brukade möta mig här på fredagar. Vi delade alltid en kanelbulle från caféet.",
                category: .family,
                latitude: workPosition.latitude,
                longitude: workPosition.longitude + 15 * degPerMeterLon
            ),
            EchoMemory(
                title: "Mjärdevis första startup",
                story: "1984 grundades första företaget här. Idén kläcktes på en servett över en kopp kaffe.",
                category: .historical,
                latitude: workPosition.latitude - 15 * degPerMeterLat,
                longitude: workPosition.longitude
            ),
            EchoMemory(
                title: "Ljuset i fönstret",
                story: "Varje natt klockan 03:00 tänds ett ljus i ett tomt kontor. Ingen vet vem som är där.",
                category: .mysterious,
                latitude: workPosition.latitude,
                longitude: workPosition.longitude - 15 * degPerMeterLon
            )
        ]

        let demoTitles = Set(demoEchoes.map { $0.title })
        let allMemories = (try? context.fetch(FetchDescriptor<EchoMemory>())) ?? []
        let existingDemos = allMemories.filter { demoTitles.contains($0.title) }

        // Städa legacy-echoes från tidigare seed-omgångar (Linköpings centrum-data).
        let legacyTitles: Set<String> = [
            "Stångåns viskningar",
            "Slottet i skuggorna",
            "Stortorgets år",
            "Sommaren -98"
        ]
        let legacyEchoes = allMemories.filter { legacyTitles.contains($0.title) }

        let workCLLocation = CLLocation(latitude: workPosition.latitude, longitude: workPosition.longitude)
        let allUpToDate = legacyEchoes.isEmpty
            && existingDemos.count == demoEchoes.count
            && existingDemos.allSatisfy { memory in
                let memoryLocation = CLLocation(latitude: memory.latitude, longitude: memory.longitude)
                return workCLLocation.distance(from: memoryLocation) < 100
            }
        if allUpToDate { return }

        existingDemos.forEach { context.delete($0) }
        legacyEchoes.forEach { context.delete($0) }
        demoEchoes.forEach { context.insert($0) }
        try? context.save()
        loadMemories(from: context)
    }
    #endif

    private func updateProximity(for userLocation: CLLocation) {
        var revealed: Set<UUID> = []
        var distances: [Double] = []
        for pin in visibleMemories {
            let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            let distance = userLocation.distance(from: pinLocation)
            distances.append(distance)
            if distance <= Self.proximityRadiusMeters {
                revealed.insert(pin.id)
            }
        }

        distanceToNearestMemory = distances.min()
        memoriesWithinRangeCount = revealed.count
        revealedPinIDs = revealed
    }

    func toggleCategory(_ category: MemoryCategory) {
        if activeCategories.contains(category) {
            activeCategories.remove(category)
        } else {
            activeCategories.insert(category)
        }
        updateMonitoringForVisibleMemories()
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
        // Idempotent: iOS ignorerar permission-request om redan svarat
        locationService.requestLocationPermission()
        locationService.startTracking()
    }

    /// Ökar `likes` med 1 på motsvarande EchoMemory.
    @discardableResult
    func likeEcho(_ pin: EchoPin, in context: ModelContext) -> Int? {
        let pinID = pin.id
        let descriptor = FetchDescriptor<EchoMemory>(predicate: #Predicate { $0.id == pinID })
        guard let memory = (try? context.fetch(descriptor))?.first else { return nil }
        memory.likes += 1
        try? context.save()
        return memory.likes
    }

    func loadMemories(from context: ModelContext) {
        let descriptor = FetchDescriptor<EchoMemory>()
        let memories = (try? context.fetch(descriptor)) ?? []
        hiddenMemories = memories.map { memory in
            EchoPin(
                id: memory.id,
                coordinate: memory.coordinate,
                category: memory.category,
                title: memory.title,
                story: memory.story,
                date: memory.date,
                imageName: memory.imageName
            )
        }
        updateMonitoringForVisibleMemories()
        if let location = locationService.userLocation {
            updateProximity(for: location)
        }
    }
}
