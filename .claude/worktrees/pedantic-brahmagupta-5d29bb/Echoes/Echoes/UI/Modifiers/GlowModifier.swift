//
//  GlowModifier.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

struct GlowModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.55), radius: 12)
            .shadow(color: color.opacity(0.25), radius: 28)
    }
}

extension View {
    func glow(_ color: Color = AppColors.primary) -> some View {
        modifier(GlowModifier(color: color))
    }
}
