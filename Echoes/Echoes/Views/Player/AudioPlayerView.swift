//
//  AudioPlayerView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//

import SwiftUI

struct AudioPlayerView: View {

    let audioURL: URL

    @Environment(AudioService.self) private var audioService
    @State private var isPlaying = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                if isPlaying {
                    ForEach(0..<3, id: \.self) { index in
                        PlayWaveRing(delay: Double(index) * 0.5)
                    }
                }

                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.primary)
                        .glow(AppColors.primary)
                }
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(isPlaying ? "Spelar upp..." : "Tryck för att lyssna")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)

                Text(audioURL.lastPathComponent)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .onDisappear {
            if isPlaying {
                audioService.stopPlayback()
                isPlaying = false
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            audioService.stopPlayback()
            isPlaying = false
        } else {
            audioService.playRecording(url: audioURL)
            isPlaying = true
        }
    }
}

/// Single expanding ring used behind the play button while audio is playing.
/// Mounted only when needed; each instance staggers its start via `delay`.
private struct PlayWaveRing: View {
    let delay: Double
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(AppColors.primary, lineWidth: 2)
            .frame(width: 48, height: 48)
            .scaleEffect(animate ? 1.8 : 0.9)
            .opacity(animate ? 0 : 0.6)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    AudioPlayerView(audioURL: URL(fileURLWithPath: "/tmp/sample.m4a"))
        .environment(AudioService())
        .padding()
        .background(AppColors.background)
}
