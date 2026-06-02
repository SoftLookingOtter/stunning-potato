//
//  MapView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Robin Eliasson on 2026-05-25
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    //  ViewModel
    @StateObject private var viewModel = MapViewModel()

    @Environment(\.modelContext) private var modelContext

    @State private var pulseProgress: Double = 0

    // Följer användarens position + roterar med gångriktningen (Pokémon GO-känsla)
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
                distance: 400 // 400 meter zoom
            )
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. map gets their 'visibleMemories' from  viewModel.swift
            Map(position: $cameraPosition) {
                UserAnnotation() // blue dot via CoreLocation

                // Pulserande 200m proximity-ring runt användaren
                if let userCoord = viewModel.userCoordinate {
                    MapCircle(center: userCoord, radius: 200)
                        .foregroundStyle(AppColors.echo.opacity(0.08 + 0.12 * pulseProgress))
                        .stroke(AppColors.echo.opacity(0.4 + 0.4 * pulseProgress), lineWidth: 1.5)
                }

                ForEach(viewModel.visibleMemories) { memory in
                    Annotation("", coordinate: memory.coordinate) {
                        EchoPinView(isRevealed: viewModel.activeRegionID == memory.id)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .preferredColorScheme(.dark)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                recenterButton
                    .padding(.trailing, 16)
                    .padding(.bottom, 180)
            }
            .overlay(alignment: .topLeading) {
                categoryFilter
                    .padding(.top, 80)
                    .padding(.leading, 16)
            }

            // 2. Proximity Banner shows when there is memories nearby
            proximityBanner
        }
        //ask for location permission and setup map when view appears
        .onAppear {
            viewModel.setupMap()
            viewModel.loadMemories(from: modelContext)
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseProgress = 1
            }
        }
    }
    
    //  - UI Components

    private var recenterButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                cameraPosition = .userLocation(
                    followsHeading: true,
                    fallback: .camera(
                        MapCamera(
                            centerCoordinate: viewModel.userCoordinate
                                ?? CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
                            distance: 400
                        )
                    )
                )
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppColors.surface)
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.border, lineWidth: 1)
                )
        }
    }

    private var categoryFilter: some View {
        VStack(spacing: 12) {
            ForEach(MemoryCategory.allCases, id: \.self) { category in
                let isActive = viewModel.activeCategories.contains(category)
                Button {
                    viewModel.toggleCategory(category)
                } label: {
                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isActive ? AppColors.background : category.color)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isActive ? category.color : category.color.opacity(0.15))
                        )
                        .overlay(
                            Circle()
                                .stroke(category.color.opacity(isActive ? 1.0 : 0.5), lineWidth: 1.5)
                        )
                        .shadow(color: isActive ? category.color.opacity(0.6) : .clear, radius: 8)
                }
                .animation(.easeInOut(duration: 0.2), value: isActive)
            }
        }
    }

    private var proximityBanner: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.echo)
                    .frame(width: 12, height: 12)
                
                Text("\(viewModel.memoriesWithinRangeCount) minnen inom 200 m")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            if let distance = viewModel.distanceToNearestMemory {
                Text("Närmaste: \(Int(distance)) m bort. Promenera för att avslöja det.")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, 20)
            } else {
                Text("Promenera för att avslöja dem")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, 20)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, 100) //place for tab-bar
    }
}

#Preview {
    MapView()
}
