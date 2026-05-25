//
//  AuthViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Migrated to Firebase Auth on 2026-05-25.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import SwiftData
import SwiftUI

/// Auth is delegated to Firebase. SwiftData keeps a local mirror of profile/stats
/// keyed by `firebaseUID`, so the rest of the app can keep working with AppUser.
@Observable
class AuthViewModel {

    var currentUser: AppUser?
    var isLoggedIn: Bool = false
    var errorMessage: String = ""

    // Held between Apple onRequest and onCompletion so Firebase can verify the token.
    private var currentNonce: String?

    // MARK: - Session restore

    /// Firebase persists the session in Keychain on its own, so we just check
    /// whether there is a current user at launch and rehydrate the local mirror.
    func restoreSession(context: ModelContext) {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        attachLocalMirror(for: firebaseUser, fallbackName: nil, context: context)
    }

    // MARK: - Register (email + password)

    func register(name: String, email: String, password: String, context: ModelContext) async {
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

        do {
            let result = try await Auth.auth().createUser(
                withEmail: normalizedEmail,
                password: password
            )
            let change = result.user.createProfileChangeRequest()
            change.displayName = trimmedName
            try? await change.commitChanges()

            attachLocalMirror(for: result.user, fallbackName: trimmedName, context: context)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Login (email + password)

    func login(email: String, password: String, context: ModelContext) async {
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Fyll i alla fält"
            return
        }

        do {
            let result = try await Auth.auth().signIn(
                withEmail: normalizedEmail,
                password: password
            )
            attachLocalMirror(for: result.user, fallbackName: nil, context: context)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Logout

    func logout() {
        try? Auth.auth().signOut()
        currentUser = nil
        isLoggedIn = false
    }

    // MARK: - Sign in with Apple → Firebase

    /// Call this from `SignInWithAppleButton.onRequest` to set the nonce and scopes.
    func makeAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func signInWithApple(result: Result<ASAuthorization, Error>, context: ModelContext) async {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Kunde inte logga in med Apple"
                return
            }
            guard let nonce = currentNonce else {
                errorMessage = "Saknar nonce"
                return
            }
            guard let tokenData = credential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Kunde inte läsa Apple-token"
                return
            }

            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: tokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )

            do {
                let result = try await Auth.auth().signIn(with: firebaseCredential)

                let fallbackName = [credential.fullName?.givenName,
                                    credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                attachLocalMirror(
                    for: result.user,
                    fallbackName: fallbackName.isEmpty ? nil : fallbackName,
                    appleUserID: credential.user,
                    context: context
                )
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
            }
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

    // MARK: - Local mirror

    /// Finds or creates the SwiftData AppUser for a Firebase user, then sets
    /// `currentUser` and flips `isLoggedIn` so the root view switches scenes.
    private func attachLocalMirror(
        for firebaseUser: FirebaseAuth.User,
        fallbackName: String?,
        appleUserID: String? = nil,
        context: ModelContext
    ) {
        let uid = firebaseUser.uid
        let descriptor = FetchDescriptor<AppUser>(
            predicate: #Predicate { $0.firebaseUID == uid }
        )

        let user: AppUser
        if let existing = try? context.fetch(descriptor).first {
            user = existing
        } else {
            let displayName = fallbackName
                ?? firebaseUser.displayName
                ?? "Echoes-användare"
            user = AppUser(
                name: displayName,
                email: firebaseUser.email ?? "",
                appleUserID: appleUserID,
                firebaseUID: uid
            )
            context.insert(user)
            try? context.save()
        }
        currentUser = user
        isLoggedIn = true
    }

    // MARK: - Apple nonce helpers

    private func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
