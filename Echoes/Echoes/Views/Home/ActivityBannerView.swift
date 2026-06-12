//
//  ActivityBannerView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import CoreLocation

struct ActivityBannerView: View {
    let echoes: [EchoMemory]
    let userLocation: CLLocation?
    let activeRegionID: UUID?

    private let nearbyRadius: CLLocationDistance = 200

    private var activeEchoInfo: (echo: EchoMemory, distance: CLLocationDistance?)? {
        if let activeRegionID,
           let echo = echoes.first(where: { $0.id == activeRegionID }) {
            return (
                echo: echo,
                distance: distance(to: echo)
            )
        }

        guard let nearest = nearestEchoInfo,
              nearest.distance <= nearbyRadius else {
            return nil
        }

        return nearest
    }

    private var nearestEchoInfo: (echo: EchoMemory, distance: CLLocationDistance)? {
        guard let userLocation else {
            return nil
        }

        return echoes
            .map { echo in
                let echoLocation = CLLocation(
                    latitude: echo.latitude,
                    longitude: echo.longitude
                )

                let distance = userLocation.distance(from: echoLocation)

                return (echo: echo, distance: distance)
            }
            .sorted { $0.distance < $1.distance }
            .first
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            statusIcon

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
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

            Image(systemName: activeEchoInfo == nil ? "sparkles" : "mappin.and.ellipse")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }

    private var title: String {
        guard activeEchoInfo != nil else {
            return "Inga minnen nära dig just nu"
        }

        return "1 minne nära dig nu"
    }

    private var subtitle: String {
        guard let activeEchoInfo else {
            return "Fortsätt utforska så dyker nya echoes upp i närheten."
        }

        let category = activeEchoInfo.echo.category.displayName

        if let distance = activeEchoInfo.distance {
            return "\(formatDistance(distance)) · \(category)"
        }

        return category
    }

    private var iconColor: Color {
        activeEchoInfo == nil ? AppColors.primary : AppColors.echo
    }

    private var backgroundColor: Color {
        activeEchoInfo == nil
        ? AppColors.surface.opacity(0.82)
        : AppColors.echo.opacity(0.16)
    }

    private var borderColor: Color {
        activeEchoInfo == nil
        ? AppColors.border
        : AppColors.echo.opacity(0.45)
    }

    private func distance(to echo: EchoMemory) -> CLLocationDistance? {
        guard let userLocation else {
            return nil
        }

        let echoLocation = CLLocation(
            latitude: echo.latitude,
            longitude: echo.longitude
        )

        return userLocation.distance(from: echoLocation)
    }

    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance.rounded())) m"
        }

        let kilometers = distance / 1000
        return String(format: "%.1f km", kilometers)
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        ActivityBannerView(
            echoes: [],
            userLocation: nil,
            activeRegionID: nil
        )
        .padding()
    }
}
