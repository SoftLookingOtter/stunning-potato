//
//  Route.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftData
import Foundation

@Model
class Route {
    var id: UUID
    var title: String
    var routeDescription: String
    var date: Date

    // One Route holds many EchoMemory objects.
    // deleteRule .nullify means deleting a Route does NOT delete the echoes.
    @Relationship(deleteRule: .nullify, inverse: \EchoMemory.route)
    var echoes: [EchoMemory]

    init(title: String, routeDescription: String = "", echoes: [EchoMemory] = []) {
        self.id = UUID()
        self.title = title
        self.routeDescription = routeDescription
        self.date = Date()
        self.echoes = echoes
    }
}
