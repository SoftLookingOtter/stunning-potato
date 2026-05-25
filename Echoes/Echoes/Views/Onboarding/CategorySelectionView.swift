//
//  CategorySelectionView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct CategorySelectionView: View {
    let categories: [String]
    @Binding var selectedCategories: Set<String>

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(spacing: AppSpacing.sm) {
                Text("category_selection_title")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)

                Text("category_selection_text")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: AppSpacing.md
            ) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        toggleCategory(category)
                    } label: {
                        CategoryChip(
                            titleKey: LocalizedStringKey(category),
                            systemImage: icon(for: category),
                            color: color(for: category),
                            isSelected: selectedCategories.contains(category)
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func icon(for category: String) -> String {
        switch category {
        case "category_nostalgia":
            return "clock.arrow.circlepath"
        case "category_history":
            return "book.closed.fill"
        case "category_events":
            return "sparkles"
        case "category_calm":
            return "moon.fill"
        case "category_mystery":
            return "eye.fill"
        default:
            return "circle.fill"
        }
    }

    private func color(for category: String) -> Color {
        switch category {
        case "category_nostalgia":
            return AppColors.nostalgia
        case "category_history":
            return AppColors.history
        case "category_events":
            return AppColors.echo
        case "category_calm":
            return AppColors.nature
        case "category_mystery":
            return AppColors.mystery
        default:
            return AppColors.primary
        }
    }
}

#Preview {
    CategorySelectionView(
        categories: [
            "category_nostalgia",
            "category_history",
            "category_events",
            "category_calm",
            "category_mystery"
        ],
        selectedCategories: .constant(["category_nostalgia", "category_mystery"])
    )
}
