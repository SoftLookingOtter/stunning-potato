//
//  PrimaryButton.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .font(AppTypography.headline)
            }
            .foregroundStyle(AppColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glow(AppColors.primary)
        }
    }
}
