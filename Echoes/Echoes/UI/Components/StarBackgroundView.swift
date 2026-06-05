//
//  StarBackgroundView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-06-03.
//

import SwiftUI

struct StarBackgroundView: View {
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.12, 0.10, 2.0, 0.35),
        (0.28, 0.18, 1.5, 0.28),
        (0.72, 0.14, 2.0, 0.35),
        (0.88, 0.26, 1.5, 0.28),
        (0.20, 0.42, 2.0, 0.30),
        (0.55, 0.36, 1.5, 0.25),
        (0.78, 0.48, 2.0, 0.34),
        (0.34, 0.62, 1.5, 0.26),
        (0.66, 0.74, 2.0, 0.30),
        (0.16, 0.82, 1.5, 0.26),
        (0.48, 0.88, 2.0, 0.30)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<stars.count, id: \.self) { index in
                let star = stars[index]

                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(
                        x: proxy.size.width * star.x,
                        y: proxy.size.height * star.y
                    )
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        StarBackgroundView()
            .ignoresSafeArea()
    }
}
