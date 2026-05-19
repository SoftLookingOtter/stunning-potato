//
//  AuthViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import AuthenticationServices
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

    // MARK: - Sign in with Apple

    func signInWithApple(result: Result<ASAuthorization, Error>, context: ModelContext) {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Kunde inte logga in med Apple"
                return
            }

            let appleUserID = credential.user

            // Returning user – look up by Apple's stable identifier
            let descriptor = FetchDescriptor<AppUser>(
                predicate: #Predicate { $0.appleUserID == appleUserID }
            )
            if let existing = try? context.fetch(descriptor).first {
                currentUser = existing
                isLoggedIn = true
                errorMessage = ""
                return
            }

            // First-time sign-in – Apple only provides name/email this once
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let displayName = fullName.isEmpty ? "Echoes-användare" : fullName
            let email = credential.email ?? ""

            let user = AppUser(name: displayName, email: email, appleUserID: appleUserID)
            context.insert(user)
            try? context.save()
            currentUser = user
            isLoggedIn = true
            errorMessage = ""
        }
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
