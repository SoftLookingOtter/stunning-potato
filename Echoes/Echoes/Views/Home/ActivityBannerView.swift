//
//  ActivityBannerView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//

import SwiftUI

struct ActivityBannerView: View {
    let echoes: [EchoMemory]

    private var recentEchoes: [EchoMemory] {
        Array(echoes.sorted { $0.date > $1.date }.prefix(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Senaste aktivitet")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(recentEchoes) { echo in
                        ActivityChip(echo: echo)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }
}

// MARK: - Single activity chip
private struct ActivityChip: View {
    let echo: EchoMemory

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: echo.category.icon)
                .font(.caption)
                .foregroundStyle(echo.category.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(echo.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text("\(echo.plays) spelade · \(echo.likes) likes")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(echo.category.color.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ActivityBannerView(echoes: [])
    }
}
