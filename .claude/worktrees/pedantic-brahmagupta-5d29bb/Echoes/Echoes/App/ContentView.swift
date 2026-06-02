//
//  ContentView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlaceholderView(title: "Hem", icon: "house.fill")
                .tabItem {
                    Label("Hem", systemImage: "house.fill")
                }

            PlaceholderView(title: "Utforska", icon: "map")
                .tabItem {
                    Label("Utforska", systemImage: "map")
                }

            RecordView()
                .tabItem {
                    Label("Spela in", systemImage: "mic.fill")
                }

            PlaceholderView(title: "Rutter", icon: "point.topleft.down.curvedto.point.bottomright.up")
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

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 70, height: 70)
                    .glow(AppColors.primary)

                Text(title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Placeholder")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    ContentView()
}
