//
//  SettingsView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-06-03.
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

            VStack(spacing: AppSpacing.lg) {
                Text("Inställningar")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.lg)

                settingsContent

                Spacer()

                logoutButton

                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Settings content

    private var settingsContent: some View {
        VStack(spacing: AppSpacing.md) {
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

    // MARK: - Logout

    private var logoutButton: some View {
        Button(role: .destructive) {
            auth.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")

                Text("Logga ut")
                    .font(AppTypography.headline)
            }
            .foregroundStyle(AppColors.people)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.people.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.people.opacity(0.35), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthViewModel())
}
