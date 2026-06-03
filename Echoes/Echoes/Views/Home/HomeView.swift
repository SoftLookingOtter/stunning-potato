//
//  HomeView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.modelContext) private var context
    @Query(HomeViewModel.allEchoesDescriptor()) private var allEchoes: [EchoMemory]

    @State private var viewModel = HomeViewModel()
    @State private var selectedCategory: MemoryCategory?

    private var filteredEchoes: [EchoMemory] {
        guard let selectedCategory else {
            return allEchoes
        }

        return allEchoes.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                HomeStarBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        header
                        statsRow

                        ActivityBannerView(echoes: allEchoes)
                            .padding(.horizontal, AppSpacing.lg)

                        categoryFilterChips
                        echoFeed
                    }
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 140)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Echoes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("God kväll")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(headerSubtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Circle()
                .fill(AppColors.echo.opacity(0.22))
                .frame(width: 52, height: 52)
                .overlay(
                    Circle()
                        .stroke(AppColors.echo.opacity(0.7), lineWidth: 2)
                )
                .overlay(
                    Text("E")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                )
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var headerSubtitle: String {
        if allEchoes.isEmpty {
            return "Börja utforska – dina första echoes väntar"
        }

        return "\(allEchoes.count) echoes väntar på att upptäckas"
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            HomeStatCard(
                value: auth.currentUser?.playsCount ?? 0,
                label: "Lyssnade",
                icon: "play.fill",
                color: AppColors.primary
            )

            HomeStatCard(
                value: auth.currentUser?.memoriesCount ?? 0,
                label: "Inspelade",
                icon: "waveform",
                color: AppColors.nature
            )

            HomeStatCard(
                value: 0,
                label: "Utforskat idag",
                icon: "figure.walk",
                color: AppColors.echo
            )
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Category filters

    private var categoryFilterChips: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("KATEGORIER")
                .font(AppTypography.smallCaps)
                .foregroundStyle(AppColors.textMuted)
                .tracking(1.4)
                .padding(.horizontal, AppSpacing.lg)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    categoryButton(nil)

                    Spacer()
                }

                HStack(alignment: .top, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        categoryButton(.historical)
                        categoryButton(.mysterious)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        categoryButton(.nostalgic)
                        categoryButton(.family)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    @ViewBuilder
    private func categoryButton(_ category: MemoryCategory?) -> some View {
        if let category {
            Button {
                selectedCategory = category
            } label: {
                CategoryChip(
                    titleKey: LocalizedStringKey(category.displayName),
                    systemImage: category.icon,
                    color: category.color,
                    isSelected: selectedCategory == category
                )
            }
            .buttonStyle(.plain)
        } else {
            Button {
                selectedCategory = nil
            } label: {
                CategoryChip(
                    titleKey: "Alla",
                    systemImage: "square.grid.2x2",
                    color: AppColors.primary,
                    isSelected: selectedCategory == nil
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Feed

    private var echoFeed: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(feedTitle)
                .font(AppTypography.smallCaps)
                .foregroundStyle(AppColors.textMuted)
                .tracking(1.4)
                .padding(.horizontal, AppSpacing.lg)

            if filteredEchoes.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: AppSpacing.xl) {
                    ForEach(filteredEchoes) { echo in
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
            }
        }
    }

    private var feedTitle: String {
        guard let selectedCategory else {
            return "SENASTE MINNEN"
        }

        return "SENASTE: \(selectedCategory.displayName.uppercased())"
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.primary)

            Text("Inga minnen hittades")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(emptyStateSubtitle)
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
        .padding(.horizontal, AppSpacing.lg)
    }

    private var emptyStateSubtitle: String {
        if let selectedCategory {
            return "Det finns inga minnen i kategorin \(selectedCategory.displayName) ännu."
        }

        return "Börja spela in eller välj en kategori för att utforska echoes."
    }
}

// MARK: - Stat card

private struct HomeStatCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)

            Text("\(value)")
                .font(AppTypography.title)
                .foregroundStyle(color)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Background

private struct HomeStarBackground: View {
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.12, 0.10, 2.0, 0.35),
        (0.28, 0.18, 1.5, 0.28),
        (0.72, 0.14, 2.0, 0.35),
        (0.88, 0.26, 1.5, 0.28),
        (0.20, 0.42, 2.0, 0.30),
        (0.55, 0.36, 1.5, 0.25),
        (0.78, 0.48, 2.0, 0.34),
        (0.34, 0.62, 1.5, 0.26),
        (0.66, 0.74, 2.0, 0.30),
        (0.16, 0.82, 1.5, 0.26),
        (0.48, 0.88, 2.0, 0.30)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<stars.count, id: \.self) { index in
                let star = stars[index]

                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(
                        x: proxy.size.width * star.x,
                        y: proxy.size.height * star.y
                    )
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
        .modelContainer(for: [EchoMemory.self, AppUser.self], inMemory: true)
}
