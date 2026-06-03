//
//  CategorySelectionView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI

struct CategorySelectionView: View {
    let categories: [MemoryCategory]
    @Binding var selectedCategories: Set<MemoryCategory>

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
                            titleKey: LocalizedStringKey(category.displayNameKey),
                            systemImage: category.icon,
                            color: category.color,
                            isSelected: selectedCategories.contains(category)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private func toggleCategory(_ category: MemoryCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

#Preview {
    CategorySelectionView(
        categories: MemoryCategory.allCases,
        selectedCategories: .constant([.nostalgic, .mysterious])
    )
}
