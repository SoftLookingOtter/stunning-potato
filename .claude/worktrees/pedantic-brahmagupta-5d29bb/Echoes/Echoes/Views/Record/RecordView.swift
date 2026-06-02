//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import SwiftUI

struct RecordView: View {
    
    @State private var viewModel = RecordViewModel()
    
    var body: some View {
        
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {

                Text(viewModel.isRecording ? "Spelar in..." : "Börja spela in")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                
                Button {
                    viewModel.toggleRecording()
                } label: {
                    
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.fill")
                        Text(viewModel.isRecording ? "Stoppa inspelning" : "Börja spela in")
                            .font(AppTypography.headline)
                    }
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        viewModel.isRecording
                        ? AppColors.people
                        : AppColors.primary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glow(
                        viewModel.isRecording
                        ? AppColors.people
                        : AppColors.primary
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    RecordView()
}

