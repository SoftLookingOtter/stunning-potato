//
//  ThemePicker.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-20.
//  Updated by Sara Lindén on 2026-06-10.
//

import SwiftUI

struct ThemePicker: View {
    
    @Binding var selectedCategory: MemoryCategory
    let isRecording: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(MemoryCategory.allCases, id: \.self) { category in
                
                Button {
                    selectedCategory = category
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: category.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(height: 20)
                        
                        Text(category.displayName)
                            .font(AppTypography.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedCategory == category
                        ? category.color
                        : AppColors.surface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
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
