//
//  HomeView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-21.

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Text("Hem")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    HomeView()
}
