//
//  CardModifier.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.md)
            .background(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

extension View {
    func appCard() -> some View {
        modifier(CardModifier())
    }
}
