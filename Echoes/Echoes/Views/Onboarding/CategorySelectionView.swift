//
//  CategorySelectionView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct CategorySelectionView: View {
    let categories: [String]
    @Binding var selectedCategory: String?

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
                        selectedCategory = category
                    } label: {
                        Text(LocalizedStringKey(category))
                            .font(AppTypography.body)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                selectedCategory == category
                                ? AppColors.background
                                : AppColors.textPrimary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                selectedCategory == category
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
}

#Preview {
    CategorySelectionView(
        categories: [
            "category_nostalgia",
            "category_history",
            "category_events"
        ],
        selectedCategory: .constant("category_nostalgia")
    )
}
