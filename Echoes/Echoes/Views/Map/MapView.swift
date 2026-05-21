//
//  MapView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//
//  Updated by Robin Eliasson on 2026-05-18


import SwiftUI
import MapKit

struct MapView: View {
    // Vi skapar och äger vår ViewModel här
    @StateObject private var viewModel = MapViewModel()
    
    // Startposition över Linköping (Används innan GPS:en hittat oss)
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
            distance: 400 // Din inzoomade nivå på 400m!
        )
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Kartan hämtar nu sina 'hiddenMemories' direkt från viewModel
            Map(position: $cameraPosition, interactionModes: .pan) {
                UserAnnotation() // Visar den blå pricken automatiskt via CoreLocation
                
                ForEach(viewModel.hiddenMemories) { memory in
                    Annotation("", coordinate: memory.coordinate) {
                        GhostPinView()
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .preferredColorScheme(.dark)
            .ignoresSafeArea()
            .mapControls {
                MapUserLocationButton()
            }
            
            VStack {
                // 2. Sökfältet (Hämtar sin text från viewModel)
                searchBar
                
                Spacer()
                
                // 3. Proximity Banner
                proximityBanner
            }
        }
        // Denna körs så fort kart-skärmen visas på telefonen.
        // Den sätter igång GPS-förfrågan och spårningen.
        .onAppear {
            viewModel.setupMap()
        }
    }
    
    // MARK: - UI Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textMuted)
            
            // Vi länkar textfältet till viewModel istället
            TextField("Sök plats...", text: $viewModel.searchText)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .cornerRadius(100)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }
    
    private var proximityBanner: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.accentPurple)
                    .frame(width: 12, height: 12)
                
                Text("\(viewModel.hiddenMemories.count) dolda minnen i närheten")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text("Promenera för att avslöja dem")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 20)
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
        .padding(.bottom, 100)
    }
}

// MARK: - Subviews
// (Din snygga GhostPinView ligger kvar här nere)
struct GhostPinView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.textMuted.opacity(0.3), lineWidth: 1)
                .frame(width: 40, height: 40)
            
            Circle()
                .stroke(AppColors.textMuted.opacity(0.5), lineWidth: 1.5)
                .frame(width: 24, height: 24)
            
            Circle()
                .fill(AppColors.textMuted)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    MapView()
}
