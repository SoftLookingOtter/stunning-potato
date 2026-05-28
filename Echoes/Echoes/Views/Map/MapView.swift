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

    // Startposition  Linköping
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 58.4108, longitude: 15.6214),
            distance: 400 // 400 meter zoom
        )
    )
    
    var body: some View {
        ZStack(alignment: .bottom) { 
            // 1. map gets their 'hiddenMemories' from  viewModel.swift
            Map(position: $cameraPosition, interactionModes: .pan) {
                UserAnnotation() // blue dot via CoreLocation
                
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
            
            // 2. Proximity Banner shows when there is memories nearby
            proximityBanner
        }
        //ask for location permission and setup map when view appears
        .onAppear {
            viewModel.setupMap()
            viewModel.loadMemories(from: modelContext)
        }
    }
    
    //  - UI Components
    
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
