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

    private var areAllCategoriesSelected: Bool {
        Set(categories).isSubset(of: selectedCategories)
    }

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

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    allCategoriesButton
                    Spacer()
                }

                HStack(alignment: .top, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        categoryButton(.nostalgic)
                        categoryButton(.family)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        categoryButton(.historical)
                        categoryButton(.mysterious)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private var allCategoriesButton: some View {
        Button {
            toggleAllCategories()
        } label: {
            CategoryChip(
                titleKey: "Alla",
                systemImage: "square.grid.2x2",
                color: AppColors.allCategories,
                isSelected: areAllCategoriesSelected
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func categoryButton(_ category: MemoryCategory) -> some View {
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

    private func toggleCategory(_ category: MemoryCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func toggleAllCategories() {
        if areAllCategoriesSelected {
            selectedCategories.removeAll()
        } else {
            selectedCategories = Set(categories)
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        StarBackgroundView()
            .ignoresSafeArea()

        CategorySelectionView(
            categories: MemoryCategory.allCases,
            selectedCategories: .constant([.nostalgic, .historical, .family, .mysterious])
        )
    }
}
