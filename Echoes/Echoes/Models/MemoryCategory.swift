//
//  MemoryCategory.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI

enum MemoryCategory: String, Codable, CaseIterable {
    case nostalgic
    case historical
    case family
    case mysterious

    var displayNameKey: String {
        switch self {
        case .nostalgic:
            return "category_nostalgia"
        case .historical:
            return "category_history"
        case .family:
            return "category_family"
        case .mysterious:
            return "category_mystery"
        }
    }

    var displayName: String {
        String(localized: String.LocalizationValue(displayNameKey))
    }

    var color: Color {
        switch self {
        case .nostalgic:
            return AppColors.nostalgia
        case .historical:
            return AppColors.history
        case .family:
            return AppColors.nature
        case .mysterious:
            return AppColors.mystery
        }
    }

    var icon: String {
        switch self {
        case .nostalgic:
            return "heart.fill"
        case .historical:
            return "clock.fill"
        case .family:
            return "house.fill"
        case .mysterious:
            return "moon.stars.fill"
        }
    }
}
