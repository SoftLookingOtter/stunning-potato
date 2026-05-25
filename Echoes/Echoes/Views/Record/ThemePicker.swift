//
//  ThemePicker.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-20

import SwiftUI

struct ThemePicker: View {
    
    @Binding var selectedCategory: MemoryCategory
    let isRecording: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(MemoryCategory.allCases, id: \.self) { category in
                
                    Button {
                        selectedCategory = category
                    } label: {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: category.icon)
                            
                            Text(category.displayName)
                                .font(AppTypography.caption)
                        }
                        
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            selectedCategory == category
                            ? category.color
                            : AppColors.surface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .disabled(isRecording)
            .opacity(isRecording ? 0.4 : 1.0)
        }
    }


#Preview {
    ThemePicker(selectedCategory: .constant(.nostalgic), isRecording: false)
}
