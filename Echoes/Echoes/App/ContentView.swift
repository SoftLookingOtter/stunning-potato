//
//  ContentView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//  Updated by Sara Lindén on 2026-05-21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Hem", systemImage: "house.fill")
                }
            
            //map (explore/utförska)

            MapView()
                .tabItem {
                    Label("Utforska", systemImage: "map")
                }

            RecordView()
                .tabItem {
                    Label("Spela in", systemImage: "mic.fill")
                }

            RouteListView()
                .tabItem {
                    Label("Rutter", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
}
