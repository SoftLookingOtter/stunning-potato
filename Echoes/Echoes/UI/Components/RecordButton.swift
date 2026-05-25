//
//  RecordButton.swift
//  Echoes
//
//  Created by Mikael Engvall on 2026-05-22.
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action:action) {
            HStack(spacing: AppSpacing.sm) {
                
                Image(systemName: isRecording ? "stop-circle.fill" : "mic.fill")
                
                Text(isRecording ? "Stoppa inspelning" : "Börja spela in")
                    .font(AppTypography.headline)
            }
            
            .foregroundStyle(AppColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isRecording
                ? AppColors.people
                : AppColors.primary
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glow(
                isRecording
                ? AppColors.people
                : AppColors.primary
            )
        }
    }
}
