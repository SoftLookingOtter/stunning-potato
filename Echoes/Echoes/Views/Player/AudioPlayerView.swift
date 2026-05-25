//
//  AudioPlayerView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-25

import SwiftUI

struct AudioPlayerView: View {
    
    @State private var isPlaying = false
    @State private var currentTime = "00:00"
    
    private let audioService = AudioService()
    
    var body: some View {
        
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColors.primary)
                        .glow(AppColors.primary)
                }
                
                Text(currentTime)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                
                WaveformView(isPlaying: isPlaying)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    AudioPlayerView()
}

struct WaveformView: View {
    
    let isPlaying: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 6,
                       height: isPlaying ? 40 : 20
                )
                
                .animation(
                    .easeInOut(duration: 0.4),
                    value: isPlaying
                )
            
            RoundedRectangle(cornerRadius: 4)

                .frame(
                    width: 6,
                    height: isPlaying ? 25 : 40
                )
                .animation(
                    .easeInOut(duration: 0.4),
                    value: isPlaying
                )
            
            RoundedRectangle(cornerRadius: 4)

                .frame(
                    width: 6,
                    height: isPlaying ? 50 : 30
                )
                .animation(
                    .easeInOut(duration: 0.4),
                    value: isPlaying
                )
            
            RoundedRectangle(cornerRadius: 4)

                .frame(
                    width: 6,
                    height: isPlaying ? 20 : 50
                )
                .animation(
                    .easeInOut(duration: 0.4),
                    value: isPlaying
                )
            
            RoundedRectangle(cornerRadius: 4)

                .frame(
                    width: 6,
                    height: isPlaying ? 45 : 25
                )
                .animation(
                    .easeInOut(duration: 0.4),
                    value: isPlaying
                )
        }
        .foregroundStyle(AppColors.primary)
        .glow(AppColors.primary)
    }
}

