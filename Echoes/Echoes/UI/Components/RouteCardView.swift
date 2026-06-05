//
//  RouteCardView.swift
//  Echoes
//
//  Created by Mikael Engvall on 2026-05-30.
//  Updated by Mikael Engvall on 2026-04-05

import SwiftUI

struct RouteCardView: View {
    
    let title: String
    let memoryCount: Int
    let distance: Double
    let rating: Double
    let category: MemoryCategory
    
    private var bannerColor: Color {
        category.color
    }
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            Rectangle()
                .fill(bannerColor)
                .frame(height: 40)
                
            
            HStack {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text("\(memoryCount) minnen - \(distance, specifier: "%.1f") km")
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text("\(rating, specifier: "%.1f")")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        RouteCardView(
            title: "Linköpings gamla handel",
            memoryCount: 6,
            distance: 1.2,
            rating: 4.8,
            category: .nostalgic
        )
            .padding()
    }
}

