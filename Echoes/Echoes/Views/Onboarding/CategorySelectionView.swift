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
                        HStack(spacing: AppSpacing.sm) {
                            Text(LocalizedStringKey(category))
                                .font(AppTypography.body)
                                .fontWeight(.medium)

                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                            }
                        }
                        .foregroundStyle(
                            selectedCategories.contains(category)
                            ? AppColors.background
                            : AppColors.textPrimary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            selectedCategories.contains(category)
                            ? AppColors.primary
                            : AppColors.surface
                        )
                        .clipShape(Capsule())
                    }
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
}

#Preview {
    CategorySelectionView(
        categories: [
            "category_nostalgia",
            "category_history",
            "category_events"
        ],
        selectedCategories: .constant(["category_nostalgia"])
    )
}
