//
//  RouteDetailView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//

import SwiftUI
import SwiftData

struct RouteDetailView: View {
    let route: Route

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if route.echoes.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.primary.opacity(0.5))
                    Text("Inga echoes på den här rutten")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        ForEach(route.echoes) { echo in
                            MemoryTicketView(
                                title: echo.title,
                                date: echo.date.formatted(date: .abbreviated, time: .omitted),
                                category: echo.category.displayName,
                                accentColor: echo.category.color,
                                imageName: echo.imageName,
                                isPlaying: false
                            ) {
                                // Audio playback — wired by Mikael
                            }
                        }
                    }
                    .padding(.vertical, AppSpacing.lg)
                }
            }
        }
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    let route = Route(title: "Stadshistoria 1800-talet")
    return NavigationStack {
        RouteDetailView(route: route)
    }
    .modelContainer(for: [Route.self, EchoMemory.self], inMemory: true)
}
