//
//  AuthViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftData
import SwiftUI

/// Handles mock local auth – no Firebase required.
/// One AppUser is stored in SwiftData and treated as the active session.
@Observable
class AuthViewModel {

    var currentUser: AppUser?
    var isLoggedIn: Bool = false
    var errorMessage: String = ""

    // MARK: - Login / Register (same logic locally)

    func login(name: String, email: String, context: ModelContext) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Fyll i alla fält"
            return
        }

        // Check if a user with this email already exists
        let descriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.email == email }
        )
        if let existing = try? context.fetch(descriptor).first {
            // Found – log them in
            currentUser = existing
            isLoggedIn = true
            errorMessage = ""
            return
        }

        // New user – create and save
        let user = AppUser(name: name, email: email)
        context.insert(user)
        try? context.save()
        currentUser = user
        isLoggedIn = true
        errorMessage = ""
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
    }

    // MARK: - Stats helpers (called after recording, playing, liking)

    func incrementMemories(context: ModelContext) {
        currentUser?.memoriesCount += 1
        try? context.save()
    }

    func incrementPlays(context: ModelContext) {
        currentUser?.playsCount += 1
        try? context.save()
    }

    func incrementLikes(context: ModelContext) {
        currentUser?.likesCount += 1
        try? context.save()
    }
}
