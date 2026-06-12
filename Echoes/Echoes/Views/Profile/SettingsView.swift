//
//  SettingsView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-06-05.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AuthViewModel.self) private var auth

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            StarBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Inställningar")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    preferencesSection
                    accountSection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle("PREFERENSER")

            notificationToggle
        }
    }

    private var notificationToggle: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.16))
                    .frame(width: 38, height: 38)

                Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Notiser")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(notificationsEnabled ? "Påslagna" : "Avstängda")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
                .tint(AppColors.primary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle("KONTO")

            logoutButton
        }
    }

    private var logoutButton: some View {
        Button(role: .destructive) {
            auth.logout()
        } label: {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.people.opacity(0.14))
                        .frame(width: 38, height: 38)

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.people)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Logga ut")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.people)

                    Text("Avsluta din session på den här enheten")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColors.people.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.people.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.smallCaps)
            .foregroundStyle(AppColors.textMuted)
            .tracking(1.4)
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
