//
//  MapView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Robin Eliasson on 2026-06-11
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    //  ViewModel
    @StateObject private var viewModel = MapViewModel()

    @Environment(\.modelContext) private var modelContext

    @State private var pulseProgress: Double = 0
    @State private var zoomDistance: Double = 400
    @State private var hasFocusedOnUser = false
    @State private var showRecordSheet = false
    @State private var selectedEcho: EchoPin?
    @State private var echoAddress: String?

    // Fri kamera — användaren kan panorera och rotera. Recenter-knappen återgår till follow.
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
            distance: 400
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                // Pulserande 200m proximity-ring runt användaren (lägst i z-order)
                if let userCoord = viewModel.userCoordinate {
                    MapCircle(center: userCoord, radius: 200)
                        .foregroundStyle(AppColors.echo.opacity(0.08 + 0.12 * pulseProgress))
                        .stroke(AppColors.echo.opacity(0.4 + 0.4 * pulseProgress), lineWidth: 1.5)
                }

                ForEach(viewModel.visibleMemories) { memory in
                    Annotation(memory.title ?? "Echo", coordinate: memory.coordinate, anchor: .center) {
                        EchoPinView(
                            isRevealed: viewModel.revealedPinIDs.contains(memory.id),
                            category: memory.category,
                            onTap: { selectedEcho = memory }
                        )
                    }
                    .annotationTitles(.hidden)
                    .annotationSubtitles(.hidden)
                }

                // User-pricken sist → alltid överst, slipper collision-culling
                if let userCoord = viewModel.userCoordinate {
                    Annotation("Du", coordinate: userCoord, anchor: .center) {
                        userLocationIndicator
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.container, edges: .bottom)
            .mapControls {
                MapCompass()
            }
            .onMapCameraChange(frequency: .continuous) { context in
                zoomDistance = context.camera.distance
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    recenterButton
                    addRecordingButton
                }
                .padding(.trailing, 16)
                .padding(.bottom, 120)
            }
            .overlay(alignment: .topLeading) {
                categoryFilter
                    .padding(.top, 80)
                    .padding(.leading, 16)
            }
            .overlay(alignment: .trailing) {
                zoomSlider
                    .padding(.trailing, 16)
            }

            if viewModel.userCoordinate == nil {
                gpsLoadingIndicator
            }

            if viewModel.memoriesWithinRangeCount > 0 {
                proximityBanner
            }
        }
        .onAppear {
            viewModel.setupMap()
            viewModel.loadMemories(from: modelContext)
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseProgress = 1
            }

            if let coord = viewModel.userCoordinate, !hasFocusedOnUser {
                hasFocusedOnUser = true
                cameraPosition = .camera(MapCamera(centerCoordinate: coord, distance: 400))
            }
        }
        .sheet(item: $selectedEcho) { echo in
            echoDetailSheet(for: echo)
        }
        .onChange(of: viewModel.userCoordinate?.latitude) { _, _ in
            guard !hasFocusedOnUser, let coord = viewModel.userCoordinate else { return }
            hasFocusedOnUser = true
            withAnimation(.easeInOut(duration: 0.6)) {
                cameraPosition = .camera(MapCamera(centerCoordinate: coord, distance: 400))
            }
            #if DEBUG
            viewModel.seedFridtunagatanDemoEchoesIfNeeded(in: modelContext)
            viewModel.seedTeknikringenDemoEchoesIfNeeded(in: modelContext)
            #endif
        }
    }

    //  - UI Components

    @ViewBuilder
    private func echoDetailSheet(for echo: EchoPin) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                MemoryTicketView(
                    title: echo.title ?? "Echo",
                    date: formattedDate(echo.date),
                    category: echo.category?.displayName ?? "ECHO",
                    accentColor: echo.category?.color ?? AppColors.echo,
                    imageName: echo.imageName,
                    onPlay: {
                        // Audio wired by Mikael
                    }
                )
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("echo_about_memory")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    if let story = echo.story, !story.isEmpty {
                        Text(story)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text(echoAddress ?? String(localized: "echo_address_loading"))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.top, AppSpacing.xs)
                }
                .padding(.horizontal, AppSpacing.lg)

                VStack(spacing: AppSpacing.sm) {
                    Button {
                        selectedEcho = nil
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cameraPosition = .camera(MapCamera(centerCoordinate: echo.coordinate, distance: 250))
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "map.fill")
                            Text("echo_action_show_on_map")
                        }
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }

                    Button {
                        viewModel.likeEcho(echo, in: modelContext)
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(AppColors.people)
                            Text("echo_action_like")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .font(AppTypography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
            .padding(.top, AppSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .presentationDetents([.medium, .large])
        .task(id: echo.id) {
            echoAddress = nil
            echoAddress = await reverseGeocode(coordinate: echo.coordinate)
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "—" }
        return date.formatted(.dateTime.day().month(.wide).year())
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
        guard let mapItems = try? await request.mapItems, let item = mapItems.first else { return nil }
        return item.address?.shortAddress ?? item.address?.fullAddress
    }

    private var gpsLoadingIndicator: some View {
        HStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.echo)
            Text("Söker din position…")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppColors.border, lineWidth: 1)
        )
        .padding(.bottom, 60)
    }

    private var userLocationIndicator: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 22, height: 22)
                .shadow(color: .black.opacity(0.3), radius: 2)

            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
        }
    }

    private var addRecordingButton: some View {
        Button {
            showRecordSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppColors.echo)
                )
                .shadow(color: AppColors.echo.opacity(0.5), radius: 6)
        }
        .sheet(isPresented: $showRecordSheet) {
            RecordView()
        }
    }

    private var recenterButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                cameraPosition = .camera(
                    MapCamera(
                        centerCoordinate: viewModel.userCoordinate
                            ?? CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
                        distance: zoomDistance
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

    private var zoomSlider: some View {
        VStack(spacing: 8) {
            Text(formatAltitude(zoomDistance))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.border, lineWidth: 1)
                )

            Slider(
                value: Binding(
                    get: { zoomDistance },
                    set: { newValue in
                        zoomDistance = newValue
                        let center = viewModel.userCoordinate
                            ?? CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214)
                        cameraPosition = .camera(MapCamera(centerCoordinate: center, distance: newValue))
                    }
                ),
                in: 100...20000,
                step: 100
            )
            .tint(AppColors.echo)
            .rotationEffect(.degrees(-90))
            .frame(width: 200)
            .frame(width: 40, height: 200)
        }
    }

    private func formatAltitude(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters)) m"
        } else {
            return String(format: "%.1f km", meters / 1000)
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
        .padding(.bottom, 8)
    }
}

#Preview {
    MapView()
}
