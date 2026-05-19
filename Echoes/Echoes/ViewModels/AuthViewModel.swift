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

    // MARK: - Register (new account)

    func register(name: String, email: String, password: String, context: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !trimmedName.isEmpty,
              !normalizedEmail.isEmpty,
              !password.isEmpty else {
            errorMessage = "Fyll i alla fält"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Lösenordet måste vara minst 6 tecken"
            return
        }

        // Block duplicate names
        let nameDescriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.name == trimmedName }
        )
        if (try? context.fetch(nameDescriptor).first) != nil {
            errorMessage = "Namnet används redan"
            return
        }

        // Block duplicate emails
        let emailDescriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )
        if (try? context.fetch(emailDescriptor).first) != nil {
            errorMessage = "E-postadressen används redan"
            return
        }

        let user = AppUser(name: trimmedName, email: normalizedEmail, password: password)
        context.insert(user)
        try? context.save()
        currentUser = user
        isLoggedIn = true
        errorMessage = ""
    }

    // MARK: - Login (existing account)

    func login(email: String, password: String, context: ModelContext) {
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Fyll i alla fält"
            return
        }

        let descriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.email == normalizedEmail }
        )
        guard let user = try? context.fetch(descriptor).first else {
            errorMessage = "Inget konto med den e-postadressen"
            return
        }
        guard user.password == password else {
            errorMessage = "Fel lösenord"
            return
        }

        currentUser = user
        isLoggedIn = true
        errorMessage = ""
    }

    // MARK: - Logout

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

            // Returning Apple user – look up by stable Apple ID
            let descriptor = FetchDescriptor<AppUser>(
                predicate: #Predicate { $0.appleUserID == appleUserID }
            )
            if let existing = try? context.fetch(descriptor).first {
                currentUser = existing
                isLoggedIn = true
                errorMessage = ""
                return
            }

            // First sign-in – Apple only provides name/email once
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

    // MARK: - Stats helpers

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
