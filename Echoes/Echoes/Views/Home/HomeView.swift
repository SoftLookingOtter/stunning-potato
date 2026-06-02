//
//  HomeView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.modelContext) private var context
    @Query(HomeViewModel.allEchoesDescriptor()) private var allEchoes: [EchoMemory]
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {

                        // MARK: Stats row
                        HStack(spacing: AppSpacing.md) {
                            HomeStatCard(
                                value: auth.currentUser?.memoriesCount ?? 0,
                                label: "Minnen",
                                icon: "waveform"
                            )
                            HomeStatCard(
                                value: auth.currentUser?.playsCount ?? 0,
                                label: "Spelade",
                                icon: "play.fill"
                            )
                            HomeStatCard(
                                value: auth.currentUser?.likesCount ?? 0,
                                label: "Likes",
                                icon: "heart.fill"
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // MARK: Activity banner
                        ActivityBannerView(echoes: allEchoes)

                        // MARK: Category filter chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.sm) {
                                Button {
                                    viewModel.selectedCategory = nil
                                } label: {
                                    CategoryChip(
                                        titleKey: "Alla",
                                        systemImage: "square.grid.2x2",
                                        color: AppColors.primary,
                                        isSelected: viewModel.selectedCategory == nil
                                    )
                                }

                                ForEach(MemoryCategory.allCases, id: \.self) { category in
                                    Button {
                                        viewModel.selectedCategory = category
                                    } label: {
                                        CategoryChip(
                                            titleKey: LocalizedStringKey(category.displayName),
                                            systemImage: category.icon,
                                            color: category.color,
                                            isSelected: viewModel.selectedCategory == category
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }

                        // MARK: Echo feed
                        LazyVStack(spacing: AppSpacing.xl) {
                            ForEach(viewModel.filtered(allEchoes)) { echo in
                                MemoryTicketView(
                                    title: echo.title,
                                    date: echo.date.formatted(date: .abbreviated, time: .omitted),
                                    category: echo.category.displayName,
                                    location: nil,
                                    imageName: echo.imageName
                                ) {
                                    viewModel.play(echo, auth: auth, in: context)
                                }
                            }
                        }
                        .padding(.bottom, AppSpacing.xl)
                    }
                    .padding(.top, AppSpacing.lg)
                }
            }
            .navigationTitle("Echoes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Stat card
private struct HomeStatCard: View {
    let value: Int
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppColors.primary)
            Text("\(value)")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
        .modelContainer(for: [EchoMemory.self, AppUser.self], inMemory: true)
}
