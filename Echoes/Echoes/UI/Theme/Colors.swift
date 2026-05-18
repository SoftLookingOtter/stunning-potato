//
//  Colors.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Sara Lindén on 2026-05-18.
//

import SwiftUI

enum AppColors {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.10)
    static let surface = Color(red: 0.10, green: 0.09, blue: 0.15)
    static let surfaceLight = Color(red: 0.16, green: 0.13, blue: 0.20)

    // Main brand color
    static let primary = Color(red: 0.95, green: 0.64, blue: 0.18)
    static let primarySoft = Color(red: 0.45, green: 0.30, blue: 0.10)

    // Category/accent colors
    static let accentPurple = Color(red: 0.55, green: 0.43, blue: 0.95)
    static let accentBlue = Color(red: 0.36, green: 0.62, blue: 0.95)
    static let accentGreen = Color(red: 0.38, green: 0.82, blue: 0.55)
    static let accentRose = Color(red: 0.95, green: 0.42, blue: 0.42)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textMuted = Color.white.opacity(0.42)

    static let border = Color.white.opacity(0.12)
}
