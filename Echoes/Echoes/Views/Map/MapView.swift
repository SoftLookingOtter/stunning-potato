//
//  MapView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-17.

import SwiftUI

struct MapView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Text("Utforska")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    MapView()
}
