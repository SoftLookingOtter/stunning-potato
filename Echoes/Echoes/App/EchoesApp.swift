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
import FirebaseCore


@main
struct EchoesApp: App {

    
    @State private var auth = AuthViewModel()
    
    init () {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                ContentView()
                    .environment(auth)
            } else {
                LoginView(auth: auth)
            }
        }
        .modelContainer(for: [EchoMemory.self, AppUser.self, Route.self]) { result in
            if case .success(let container) = result {
                SeedDataService.seedIfNeeded(context: container.mainContext)
                auth.restoreSession(context: container.mainContext)
            }
        }
    }
}
