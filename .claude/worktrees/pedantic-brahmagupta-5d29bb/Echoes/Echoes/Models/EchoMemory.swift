//
//  EchoMemory.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
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
        self.likes = 0
        self.plays = 0
    }
}
