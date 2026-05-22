//
//  OnboardingView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedCategory: String?
    @State private var currentStep = 0

    private let categories = [
        "category_nostalgia",
        "category_history",
        "category_events",
        "category_calm",
        "category_mystery"
    ]

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                topBar

                Spacer()

                if currentStep == 0 {
                    introStep
                } else if currentStep == 1 {
                    CategorySelectionView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                } else {
                    PermissionView()
                }

                Spacer()

                PrimaryButton(buttonTitle) {
                    handleNextStep()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
    }

    private var topBar: some View {
        HStack {
            if currentStep > 0 {
                Button {
                    currentStep -= 1
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("back_button")
                    }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }

    private var introStep: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(AppColors.primary)

            Text("onboarding_welcome_title")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("onboarding_welcome_text")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
    }

    private var buttonTitle: String {
        currentStep == 2
        ? String(localized: "get_started_button")
        : String(localized: "continue_button")
    }

    private func handleNextStep() {
        if currentStep < 2 {
            currentStep += 1
        } else {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
