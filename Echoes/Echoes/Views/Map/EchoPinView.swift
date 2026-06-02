//
//  EchoPinView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Robin Eliasson on 2026-05-27
//

import SwiftUI

struct EchoPinView: View {
    let isRevealed: Bool

    var body: some View {
        ZStack {
            if isRevealed {
                RevealedPinView()
                    .transition(.scale.combined(with: .opacity))
            } else {
                GhostPinView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRevealed)
    }
}

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

struct RevealedPinView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.echo.opacity(0.35))
                .frame(width: 60, height: 60)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .opacity(pulse ? 0.0 : 0.6)

            Circle()
                .stroke(AppColors.echo, lineWidth: 2)
                .frame(width: 40, height: 40)

            Circle()
                .fill(AppColors.echo)
                .frame(width: 16, height: 16)
                .shadow(color: AppColors.echo, radius: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 60) {
        EchoPinView(isRevealed: false)
        EchoPinView(isRevealed: true)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.background)
}
