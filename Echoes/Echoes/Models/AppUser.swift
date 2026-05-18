//
//  AppUser.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftData
import Foundation

@Model
class AppUser {
    var id: UUID
    var name: String
    var email: String
    var isActive: Bool

    // Stats – updated locally as the user records, plays and likes echoes
    var memoriesCount: Int
    var playsCount: Int
    var likesCount: Int

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.isActive = true
        self.memoriesCount = 0
        self.playsCount = 0
        self.likesCount = 0
    }
}
