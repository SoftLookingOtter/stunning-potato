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

    // Brand
    static let primary = Color(red: 0.95, green: 0.64, blue: 0.18)
    static let primarySoft = Color(red: 0.45, green: 0.30, blue: 0.10)

    // Categories
    static let echo = Color(red: 0.55, green: 0.43, blue: 0.95)
    static let history = Color(red: 0.36, green: 0.62, blue: 0.95)
    static let nature = Color(red: 0.38, green: 0.82, blue: 0.55)
    static let people = Color(red: 0.95, green: 0.42, blue: 0.42)
    static let nostalgia = Color(red: 0.95, green: 0.64, blue: 0.18)
    static let mystery = Color(red: 0.62, green: 0.46, blue: 0.86)

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textMuted = Color.white.opacity(0.42)

    // Borders
    static let border = Color.white.opacity(0.12)
}
