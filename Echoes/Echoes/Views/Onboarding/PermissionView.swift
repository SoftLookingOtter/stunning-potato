//
//  PermissionView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct PermissionView: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(AppColors.primary)

                Text("permissions_title")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)

                Text("permissions_text")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            VStack(spacing: AppSpacing.md) {
                permissionRow(
                    icon: "location.fill",
                    title: "permission_location_title",
                    text: "permission_location_text"
                )

                permissionRow(
                    icon: "mic.fill",
                    title: "permission_microphone_title",
                    text: "permission_microphone_text"
                )

                permissionRow(
                    icon: "camera.fill",
                    title: "permission_camera_title",
                    text: "permission_camera_text"
                )

                permissionRow(
                    icon: "photo.fill",
                    title: "permission_photos_title",
                    text: "permission_photos_text"
                )

                permissionRow(
                    icon: "bell.fill",
                    title: "permission_notifications_title",
                    text: "permission_notifications_text"
                )
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private func permissionRow(
        icon: String,
        title: LocalizedStringKey,
        text: LocalizedStringKey
    ) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Text(text)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PermissionView()
}
