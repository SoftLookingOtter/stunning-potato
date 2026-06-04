//
//  RouteDetailView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-06-02.
//

import SwiftUI
import SwiftData
import MapKit

struct RouteDetailView: View {
    let route: Route

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if route.echoes.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.primary.opacity(0.5))
                    Text("Inga echoes på den här rutten")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                VStack(spacing: 0) {
                    routeMap

                    ScrollView {
                        VStack(spacing: AppSpacing.xl) {
                            ForEach(route.echoes) { echo in
                                MemoryTicketView(
                                    title: echo.title,
                                    date: echo.date.formatted(date: .abbreviated, time: .omitted),
                                    category: echo.category.displayName,
                                    location: nil,
                                    imageName: echo.imageName
                                ) {
                                    // Audio playback — wired by Mikael
                                }
                            }
                        }
                        .padding(.vertical, AppSpacing.lg)
                    }
                }
            }
        }
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Route Map

    private var routeMap: some View {
        Map(initialPosition: routeCameraPosition) {
            ForEach(route.echoes) { echo in
                Annotation(echo.title, coordinate: echo.coordinate) {
                    EchoPinView(isRevealed: true)
                }
            }

            MapPolyline(coordinates: route.echoes.map { $0.coordinate })
                .stroke(AppColors.echo, lineWidth: 3)
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .preferredColorScheme(.dark)
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private var routeCameraPosition: MapCameraPosition {
        let coordinates = route.echoes.map { $0.coordinate }
        guard let firstCoord = coordinates.first else {
            return .camera(MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
                distance: 1000
            ))
        }

        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        let minLat = lats.min() ?? firstCoord.latitude
        let maxLat = lats.max() ?? firstCoord.latitude
        let minLon = lons.min() ?? firstCoord.longitude
        let maxLon = lons.max() ?? firstCoord.longitude

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.005, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.005, (maxLon - minLon) * 1.5)
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }
}

#Preview {
    let route = Route(title: "Stadshistoria 1800-talet")
    return NavigationStack {
        RouteDetailView(route: route)
    }
    .modelContainer(for: [Route.self, EchoMemory.self], inMemory: true)
}
