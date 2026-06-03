//
//  CategoryChip.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI

struct CategoryChip: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let color: Color
    var isSelected: Bool = false
    var width: CGFloat = 132

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption)
                .frame(width: 16)

            Text(titleKey)
                .font(AppTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 4)

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .opacity(isSelected ? 1 : 0)
        }
        .foregroundStyle(isSelected ? AppColors.background : color)
        .frame(width: width)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? color : color.opacity(0.12))
        .overlay(
            Capsule()
                .stroke(color.opacity(0.8), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
