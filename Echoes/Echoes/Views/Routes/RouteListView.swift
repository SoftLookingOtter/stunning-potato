//
//  RouteListView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-21.

import SwiftUI

struct RouteListView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Text("Rutter")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    RouteListView()
}
