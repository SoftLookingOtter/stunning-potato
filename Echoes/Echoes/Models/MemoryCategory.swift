//
//  MemoryCategory.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftUI

enum MemoryCategory: String, Codable, CaseIterable {
    case nostalgic  = "Nostalgisk"
    case historical = "Historisk"
    case family     = "Familj"
    case mysterious = "Mystisk"

    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .nostalgic:  return AppColors.primary
        case .historical: return AppColors.accentBlue
        case .family:     return AppColors.accentGreen
        case .mysterious: return AppColors.accentPurple
        }
    }

    var icon: String {
        switch self {
        case .nostalgic:  return "heart.fill"
        case .historical: return "clock.fill"
        case .family:     return "house.fill"
        case .mysterious: return "moon.stars.fill"
        }
    }
}
