//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import SwiftUI

struct RecordView: View {
    
    @State private var viewModel = RecordViewModel()
    @State private var selectedCategory: MemoryCategory = .nostalgic
    
    var body: some View {
        
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {

                Text(viewModel.isRecording ? "Spelar in..." : "Börja spela in")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                
                ThemePicker(selectedCategory: $selectedCategory,
                            isRecording: viewModel.isRecording)
                
                RecordButton(isRecording: viewModel.isRecording) {
                    viewModel.toggleRecording()
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    RecordView()
}

