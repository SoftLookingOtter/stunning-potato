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
    var password: String        
    var isActive: Bool

    // Stable identifier returned by Sign in with Apple; nil for email/password users
    var appleUserID: String?

    // Firebase Authentication UID – primary key for cloud-backed accounts
    var firebaseUID: String?

    // Stats – updated locally as the user records, plays and likes echoes
    var memoriesCount: Int
    var playsCount: Int
    var likesCount: Int

    // Local profile data
    var joinDate: Date
    var bio: String
    var avatarImageName: String?

    init(name: String,
         email: String,
         password: String = "",
         appleUserID: String? = nil,
         firebaseUID: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.password = password
        self.isActive = true
        self.appleUserID = appleUserID
        self.firebaseUID = firebaseUID
        self.memoriesCount = 0
        self.playsCount = 0
        self.likesCount = 0
        self.joinDate = Date()
        self.bio = ""
        self.avatarImageName = nil
    }
}
