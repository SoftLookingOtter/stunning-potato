//
//  ThemePicker.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-20

import SwiftUI

struct ThemePicker: View {
    
    @Binding var selectedCategory: MemoryCategory
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: AppSpacing.md) {
                
                ForEach(MemoryCategory.allCases, id: \.self) { category in
                
                    Button {
                        selectedCategory = category
                    } label: {
                        
                        HStack(spacing: AppSpacing.sm) {
                            
                            Image(systemName: category.icon)
                            
                            Text(category.displayName)
                                .font(AppTypography.caption)
                        }
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            selectedCategory == category
                            ? category.color
                            : AppColors.surface
                        )
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

