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
    var password: String        // plain text – demo only, not for production
    var isActive: Bool

    // Stable identifier returned by Sign in with Apple; nil for email/password users
    var appleUserID: String?

    // Stats – updated locally as the user records, plays and likes echoes
    var memoriesCount: Int
    var playsCount: Int
    var likesCount: Int

    init(name: String, email: String, password: String = "", appleUserID: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.password = password
        self.isActive = true
        self.appleUserID = appleUserID
        self.memoriesCount = 0
        self.playsCount = 0
        self.likesCount = 0
    }
}
