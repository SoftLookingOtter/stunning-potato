//
//  RouteDetailView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//  Updated by Mikael Engvall on 2026-06-03

import SwiftUI
import SwiftData

struct RouteDetailView: View {
    let route: Route
    
    @State private var audioService = AudioService()

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
                                location: nil,
                                imageName: echo.imageName
                            ) {
                                
                                guard let path = echo.audioFilePath else {
                                    print("Ingen ljudfil hittades")
                                    return
                                }
                                
                                let url = URL(fileURLWithPath: path)
                                
                                audioService.playRecording(url: url)

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
