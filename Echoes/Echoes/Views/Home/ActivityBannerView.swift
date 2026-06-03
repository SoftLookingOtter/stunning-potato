//
//  ActivityBannerView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI

struct ActivityBannerView: View {
    let echoes: [EchoMemory]

    private var nearestEcho: EchoMemory? {
        echoes.sorted { $0.date > $1.date }.first
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            statusIcon

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.18))
                .frame(width: 36, height: 36)

            Image(systemName: nearestEcho == nil ? "location.slash" : "mappin.and.ellipse")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }

    private var title: String {
        if nearestEcho == nil {
            return "Inga minnen nära dig just nu"
        }

        return "1 minne nära dig nu"
    }

    private var subtitle: String {
        guard let nearestEcho else {
            return "Fortsätt utforska så dyker nya echoes upp i närheten."
        }

        return "140 m · Storgatan · \(nearestEcho.category.displayName)"
    }

    private var iconColor: Color {
        nearestEcho == nil ? AppColors.textMuted : AppColors.echo
    }

    private var backgroundColor: Color {
        nearestEcho == nil
        ? AppColors.surface.opacity(0.82)
        : AppColors.echo.opacity(0.16)
    }

    private var borderColor: Color {
        nearestEcho == nil
        ? AppColors.border
        : AppColors.echo.opacity(0.45)
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        ActivityBannerView(echoes: [])
            .padding()
    }
}
