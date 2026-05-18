//
//  CategoryChip.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let systemImage: String
    let color: Color
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)

            Text(title)
                .font(AppTypography.caption)
        }
        .foregroundStyle(isSelected ? AppColors.background : color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? color : color.opacity(0.12))
        .overlay(
            Capsule()
                .stroke(color.opacity(0.8), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
