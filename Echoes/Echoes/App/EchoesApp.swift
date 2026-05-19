//
//  EchoesApp.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//  Updated by Ibrahim on 2026-05-18. — Added ModelContainer + AuthViewModel
//

import SwiftUI
import SwiftData

@main
struct EchoesApp: App {

    // Ibrahim: AuthViewModel lives here so it survives navigation
    @State private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                ContentView()
                    .environment(auth)
            } else {
                LoginView(auth: auth)
            }
        }
        // Ibrahim: registers all SwiftData models and seeds demo data on first launch
        .modelContainer(for: [EchoMemory.self, AppUser.self, Route.self]) { result in
            if case .success(let container) = result {
                SeedDataService.seedIfNeeded(context: container.mainContext)
            }
        }
    }
}
