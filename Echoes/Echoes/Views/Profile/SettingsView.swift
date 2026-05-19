//
//  SettingsView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AuthViewModel.self) private var auth
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack (spacing: AppSpacing.lg) {
                Text("Inställningar")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.lg)
                
                Spacer()
                
                // Sign out button
                Button(role: .destructive) {
                    auth.logout()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logga ut")
                            .font(AppTypography.headline)
                    }
                    .foregroundStyle(AppColors.accentRose)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.accentRose.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                }
                Spacer ()
                
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}
