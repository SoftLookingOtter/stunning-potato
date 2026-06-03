//
//  RouteListView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-30.
//  Updated by Ibrahim on 2026-06-02.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import SwiftData

struct RouteListView: View {

    @Query(RouteViewModel.allRoutesDescriptor()) private var routes: [Route]
    @Environment(\.modelContext) private var context
    @State private var viewModel = RouteViewModel()
    @State private var selectedCategory: MemoryCategory?
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                StarBackgroundView()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Rutter")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)

                    Button {
                        withAnimation {
                            showFilters.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Filter")
                        }
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.surface.opacity(0.88))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if showFilters {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Button {
                                selectedCategory = nil
                            } label: {
                                CategoryChip(
                                    titleKey: "Alla",
                                    systemImage: "square.grid.2x2",
                                    color: AppColors.allCategories,
                                    isSelected: selectedCategory == nil
                                )
                            }
                            .buttonStyle(.plain)

                            ForEach(MemoryCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    CategoryChip(
                                        titleKey: LocalizedStringKey(category.displayNameKey),
                                        systemImage: category.icon,
                                        color: category.color,
                                        isSelected: selectedCategory == category
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.surface.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }

                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            if routes.isEmpty {
                                emptyState
                            } else {
                                ForEach(routes, id: \.id) { route in
                                    NavigationLink(destination: RouteDetailView(route: route)) {
                                        RouteCardView(
                                            title: route.title,
                                            memoryCount: route.echoes.count,
                                            distance: 0,
                                            rating: 0
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical, AppSpacing.md)
                        .padding(.bottom, 110)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
            }
            .navigationTitle("Rutter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppColors.primary.opacity(0.7))

            Text("Inga rutter ännu")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("När rutter skapas visas de här.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.surface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    RouteListView()
        .modelContainer(for: [Route.self, EchoMemory.self], inMemory: true)
}
