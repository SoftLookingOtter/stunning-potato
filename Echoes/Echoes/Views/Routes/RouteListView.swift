//
//  RouteListView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-30.
//  Updated by Ibrahim on 2026-06-02.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import SwiftData

struct RouteListView: View {

    @Query(sort: \EchoMemory.date, order: .reverse) private var allEchoes: [EchoMemory]
    @State private var viewModel = RouteViewModel()
    @State private var selectedCategory: MemoryCategory?
    @State private var showFilters = false
    
    @State private var playbackService = PlaybackService()
    @State private var currentlyPlayingID: UUID?
    
    private var SavedEchoes: [EchoMemory] {
        allEchoes.filter {
            $0.audioFilePath != nil
        }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                StarBackgroundView()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Sparade Echon")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button {
                        withAnimation {
                            showFilters.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Filter")
                        }
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.surface.opacity(0.88))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if showFilters {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Button {
                                selectedCategory = nil
                            } label: {
                                CategoryChip(
                                    titleKey: "Alla",
                                    systemImage: "square.grid.2x2",
                                    color: AppColors.allCategories,
                                    isSelected: selectedCategory == nil
                                )
                            }
                            .buttonStyle(.plain)

                            ForEach(MemoryCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    CategoryChip(
                                        titleKey: LocalizedStringKey(category.displayNameKey),
                                        systemImage: category.icon,
                                        color: category.color,
                                        isSelected: selectedCategory == category
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.surface.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }

                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            if SavedEchoes.isEmpty {
                                emptyState
                            } else {
                                ForEach(SavedEchoes) {
                                    echo in
                                    MemoryTicketView(
                                        title: echo.title,
                                        date: echo.date.formatted(date: .abbreviated, time: .omitted),
                                        category: echo.category.displayName,
                                        accentColor: echo.category.color,
                                        imageName: echo.imageName,
                                        isPlaying: false,
                                        onPlay: {})
                                    
                                }
                            }
                        }
                        .padding(.vertical, AppSpacing.md)
                        .padding(.bottom, 110)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func handelPlay(for echo: EchoMemory) {
        guard let path = echo.audioFilePath else { return }
    
        if currentlyPlayingID == echo.id {
            playbackService.stop()
            currentlyPlayingID = nil
        } else {
            playbackService.stop()
            playbackService.play(path: path)
            currentlyPlayingID = echo.id
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(uiImage: .echoTabIcon(size: 42))
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppColors.primary.opacity(0.7))

            Text("Inga sparade Echon")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("När du sparar Echon visas de här.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.surface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    RouteListView()
        .modelContainer(for: [Route.self, EchoMemory.self], inMemory: true)
}
