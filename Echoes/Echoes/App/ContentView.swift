//
//  ContentView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            TabView {
                HomeView()
                    .tabItem {
                        Label("tab_home", systemImage: "house.fill")
                    }

                MapView()
                    .tabItem {
                        Label("tab_map", systemImage: "map")
                    }

                RecordView()
                    .tabItem {
                        Label("tab_record", systemImage: "mic.fill")
                    }

                RouteListView()
                    .tabItem {
                        Label("tab_routes", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    }

                ProfileView()
                    .tabItem {
                        Label("tab_profile", systemImage: "person")
                    }
            }
            .tint(AppColors.primary)
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
