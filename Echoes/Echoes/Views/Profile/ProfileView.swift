//
//  ProfileView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-05.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth
    @Query(HomeViewModel.allEchoesDescriptor()) private var allEchoes: [EchoMemory]

    private var userInitial: String {
        let name = auth.currentUser?.name ?? "Användare"
        return String(name.prefix(1)).uppercased()
    }

    private var myRecordedMemories: [EchoMemory] {
        Array(
            allEchoes
                .filter { $0.audioFilePath != nil }
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
                    VStack(spacing: AppSpacing.xl) {
                        profileHeader
                        statsRow
                        myMemoriesSection
                        settingsLink

                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.echo.opacity(0.22))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Circle()
                            .stroke(AppColors.echo.opacity(0.7), lineWidth: 2)
                    )

                Text(userInitial)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .glow(AppColors.echo)

            Text(auth.currentUser?.name ?? "Användare")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(auth.currentUser?.email ?? "")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            EchoStatCard(
                value: auth.currentUser?.memoriesCount ?? myRecordedMemories.count,
                label: "Minnen",
                icon: "waveform",
                color: AppColors.nature
            )

            EchoStatCard(
                value: auth.currentUser?.playsCount ?? 0,
                label: "Lyssnade",
                icon: "play.fill",
                color: AppColors.primary
            )

            EchoStatCard(
                value: auth.currentUser?.likesCount ?? 0,
                label: "Likes",
                icon: "heart.fill",
                color: AppColors.echo
            )
        }
    }

    // MARK: - My memories

    private var myMemoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("MINA MINNEN")
                .font(AppTypography.smallCaps)
                .foregroundStyle(AppColors.textMuted)
                .tracking(1.4)

            if myRecordedMemories.isEmpty {
                emptyMemoriesState
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(myRecordedMemories) { echo in
                        ProfileMemoryRow(echo: echo)
                    }
                }
            }
        }
    }

    private var emptyMemoriesState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "mic.badge.plus")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.primary)

            Text("Inga egna minnen ännu")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Spela in ditt första echo så visas det här.")
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

    // MARK: - Settings

    private var settingsLink: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack {
                Image(systemName: "gearshape")

                Text("Inställningar")
                    .font(AppTypography.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(AppTypography.caption)
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(AppSpacing.md)
            .background(AppColors.surface.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile memory row

private struct ProfileMemoryRow: View {
    let echo: EchoMemory

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

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
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

    private var subtitle: String {
        "\(echo.category.displayName) · Skapad \(echo.date.formatted(date: .abbreviated, time: .omitted))"
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
        .modelContainer(for: [EchoMemory.self, AppUser.self], inMemory: true)
}
