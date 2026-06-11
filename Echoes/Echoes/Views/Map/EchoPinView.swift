//
//  EchoPinView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Robin Eliasson on 2026-06-11
//

import SwiftUI

struct EchoPinView: View {
    let isRevealed: Bool
    var category: MemoryCategory? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        ZStack {
            if isRevealed {
                RevealedPinView(category: category)
                    .transition(.scale.combined(with: .opacity))
            } else {
                GhostPinView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRevealed)
        .contentShape(Circle())
        .onTapGesture {
            if isRevealed {
                onTap?()
            }
        }
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
    let category: MemoryCategory?
    @State private var pulse = false

    private var tint: Color {
        category?.color ?? AppColors.echo
    }

    private var icon: String {
        category?.icon ?? "sparkles"
    }

    var body: some View {
        ZStack {
            // Statisk yttre ring — opacity skiftar mellan tydlig och dämpad
            Circle()
                .stroke(tint.opacity(pulse ? 0.25 : 0.75), lineWidth: 2)
                .frame(width: 56, height: 56)

            // Inner cirkel pulserar mellan full kategorifärg och dämpad
            Circle()
                .fill(tint.opacity(pulse ? 0.4 : 1.0))
                .frame(width: 44, height: 44)
                .shadow(color: tint.opacity(pulse ? 0.15 : 0.7), radius: 8)

            // Kategori-ikonen
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white.opacity(pulse ? 0.55 : 1.0))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 60) {
        EchoPinView(isRevealed: false)
        EchoPinView(isRevealed: true, category: .nostalgic)
        EchoPinView(isRevealed: true, category: .historical)
        EchoPinView(isRevealed: true, category: .family)
        EchoPinView(isRevealed: true, category: .mysterious)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.background)
}
