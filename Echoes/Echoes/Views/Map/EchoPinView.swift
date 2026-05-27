//
//  EchoPinView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Robin Eliasson on 2026-05-26
//

import SwiftUI

struct GhostPinView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.textMuted.opacity(0.3), lineWidth: 1)
                .frame(width: 40, height: 40)

            Circle()
                .stroke(AppColors.textMuted.opacity(0.5), lineWidth: 1.5)
                .frame(width: 24, height: 24)

            Circle()
                .fill(AppColors.textMuted)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    GhostPinView()
        .padding()
        .background(AppColors.background)
}
