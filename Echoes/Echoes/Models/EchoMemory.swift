//
//  EchoMemory.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftData
import Foundation
import CoreLocation

@Model
class EchoMemory {
    var id: UUID
    var title: String
    var story: String
    var date: Date
    var category: MemoryCategory
    var latitude: Double
    var longitude: Double
    var audioFilePath: String?
    var imageName: String?
    var likes: Int
    var plays: Int
    var discoveredAt: Date?

    var route: Route?

    // Computed helper for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        title: String,
        story: String,
        date: Date = Date(),
        category: MemoryCategory,
        latitude: Double,
        longitude: Double
    ) {
        self.id = UUID()
        self.title = title
        self.story = story
        self.date = date
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.audioFilePath = nil
        self.imageName = nil
        self.likes = 0
        self.plays = 0
        self.discoveredAt = nil
    }

    /// Convenience for creating an EchoMemory from a finished audio recording.
    /// Stores the file's local path on disk so playback can resolve it later.
    convenience init(
        recordingAt url: URL,
        title: String,
        story: String,
        date: Date = Date(),
        category: MemoryCategory,
        latitude: Double,
        longitude: Double
    ) {
        self.init(
            title: title,
            story: story,
            date: date,
            category: category,
            latitude: latitude,
            longitude: longitude
        )

        self.audioFilePath = url.path
    }
}
