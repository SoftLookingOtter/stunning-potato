//
//  CategoryChip.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct CategoryChip: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let color: Color
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)

            Text(titleKey)
                .font(AppTypography.caption)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
            }
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
