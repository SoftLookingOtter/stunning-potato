//
//  OnboardingView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedCategories") private var selectedCategoriesStorage = ""

    @State private var selectedCategories: Set<String> = []
    @State private var currentStep = 0
    @State private var isRequestingPermissions = false

    private let locationService = LocationService()
    private let audioService = AudioService()
    private let photoStorageService = PhotoStorageService()
    private let notificationService = NotificationService()

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
                        selectedCategories: $selectedCategories
                    )
                } else {
                    PermissionView()
                }

                Spacer()

                PrimaryButton(buttonTitle) {
                    handleNextStep()
                }
                .disabled(isRequestingPermissions)
                .opacity(isRequestingPermissions ? 0.6 : 1)
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
        if isRequestingPermissions {
            return String(localized: "permissions_requesting_button")
        }

        if currentStep == 2 {
            return String(localized: "permissions_allow_button")
        }

        return String(localized: "continue_button")
    }

    private func handleNextStep() {
        if currentStep < 2 {
            currentStep += 1
        } else {
            requestPermissionsAndFinish()
        }
    }

    private func requestPermissionsAndFinish() {
        isRequestingPermissions = true
        saveSelectedCategories()

        Task {
            _ = await locationService.requestLocationPermission()
            _ = await audioService.requestMicrophonePermission()
            _ = await photoStorageService.requestCameraPermission()
            _ = await photoStorageService.requestPhotoLibraryPermission()
            _ = await notificationService.requestNotificationPermission()

            await MainActor.run {
                isRequestingPermissions = false
                hasCompletedOnboarding = true
            }
        }
    }

    private func saveSelectedCategories() {
        selectedCategoriesStorage = selectedCategories.joined(separator: ",")
    }
}

#Preview {
    OnboardingView()
}
