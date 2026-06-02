//
//  RouteListView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-30.
//  Updated by Ibrahim on 2026-06-02.
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
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.surface)
                        .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if showFilters {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Button {
                                selectedCategory = nil
                            } label: {
                                CategoryChip(
                                    titleKey: "Alla",
                                    systemImage: "square.grid.2x2",
                                    color: AppColors.primary,
                                    isSelected: selectedCategory == nil
                                )
                            }

                            ForEach(MemoryCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    CategoryChip(
                                        titleKey: LocalizedStringKey(category.displayName),
                                        systemImage: category.icon,
                                        color: category.color,
                                        isSelected: selectedCategory == category
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            ForEach(routes, id: \.id) { route in
                                NavigationLink(destination: RouteDetailView(route: route)) {
                                    RouteCardView(
                                        title: route.title,
                                        memoryCount: route.echoes.count,
                                        distance: 0,
                                        rating: 0
                                    )
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding()
                }
            }
            .navigationTitle("Rutter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    RouteListView()
        .modelContainer(for: [Route.self, EchoMemory.self], inMemory: true)
}
