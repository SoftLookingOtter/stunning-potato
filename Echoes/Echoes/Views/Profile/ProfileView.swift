//
//  ProfileView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                StarBackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {

                        // MARK: Avatar + name
                        VStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.surface)
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Circle()
                                            .stroke(AppColors.primary.opacity(0.4), lineWidth: 2)
                                    )

                                Image(systemName: "person.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(AppColors.primary)
                            }
                            .glow(AppColors.primary)

                            Text(auth.currentUser?.name ?? "Användare")
                                .font(AppTypography.title)
                                .foregroundStyle(AppColors.textPrimary)

                            Text(auth.currentUser?.email ?? "")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        // MARK: Stats
                        HStack(spacing: AppSpacing.md) {
                            StatCard(
                                value: auth.currentUser?.memoriesCount ?? 0,
                                label: "Minnen"
                            )

                            StatCard(
                                value: auth.currentUser?.playsCount ?? 0,
                                label: "Spelade"
                            )

                            StatCard(
                                value: auth.currentUser?.likesCount ?? 0,
                                label: "Likes"
                            )
                        }

                        // MARK: Settings link → sign-out lives there
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
}

// MARK: - Stat card

private struct StatCard: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("\(value)")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}
