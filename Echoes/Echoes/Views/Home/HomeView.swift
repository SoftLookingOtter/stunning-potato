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
    @StateObject private var locationService = LocationService()

    private var userInitial: String {
        let name = auth.currentUser?.name ?? "Echoes"
        return String(name.prefix(1)).uppercased()
    }

    private var firstName: String {
        let name = auth.currentUser?.name ?? "du"
        return name.components(separatedBy: " ").first ?? name
    }

    private var latestEchoes: [EchoMemory] {
        Array(
            allEchoes
                .sorted {
                    ($0.discoveredAt ?? $0.date) > ($1.discoveredAt ?? $1.date)
                }
                .prefix(3)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                StarBackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        header
                        statsRow

                        ActivityBannerView(
                            echoes: allEchoes,
                            userLocation: locationService.userLocation,
                            activeRegionID: locationService.activeRegionID
                        )
                        .padding(.horizontal, AppSpacing.lg)

                        echoFeed
                    }
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                locationService.startTracking()
            }
            .onDisappear {
                locationService.stopTracking()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("God kväll, \(firstName)")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Redo att upptäcka något nytt?")
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
                    Text(userInitial)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                )
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            EchoStatCard(
                value: auth.currentUser?.playsCount ?? 0,
                label: "Lyssnade",
                icon: "play.fill",
                color: AppColors.primary
            )

            EchoStatCard(
                value: auth.currentUser?.memoriesCount ?? 0,
                label: "Inspelade",
                icon: "waveform",
                color: AppColors.nature
            )

            EchoStatCard(
                value: 0,
                label: "Utforskat idag",
                icon: "figure.walk",
                color: AppColors.echo
            )
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Feed

    private var echoFeed: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("SENASTE MINNEN")
                .font(AppTypography.smallCaps)
                .foregroundStyle(AppColors.textMuted)
                .tracking(1.4)
                .padding(.horizontal, AppSpacing.lg)

            if latestEchoes.isEmpty {
                emptyState
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(latestEchoes) { echo in
                        HomeEchoRow(echo: echo) {
                            viewModel.play(echo, auth: auth, in: context)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.primary)

            Text("Inga minnen hittades")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Börja spela in eller utforska kartan för att hitta echoes.")
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
}

// MARK: - Stat card

private struct HomeStatCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Echo row

private struct HomeEchoRow: View {
    let echo: EchoMemory
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(echo.category.color.opacity(0.18))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: echo.category.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(echo.category.color)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(echo.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(echoSubtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .frame(width: 30, height: 30)
                    .background(AppColors.primary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var echoSubtitle: String {
        if let discoveredAt = echo.discoveredAt {
            return "\(echo.category.displayName) · Upptäckt \(discoveredAt.formatted(date: .abbreviated, time: .omitted))"
        }

        return "\(echo.category.displayName) · Skapad \(echo.date.formatted(date: .abbreviated, time: .omitted))"
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
        .modelContainer(for: [EchoMemory.self, AppUser.self], inMemory: true)
}
