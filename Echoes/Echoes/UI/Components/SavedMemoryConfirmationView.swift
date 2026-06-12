//
//  SavedMemoryConfirmationView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-06-10.
//

import SwiftUI

struct SavedMemoryConfirmationView: View {
    let echo: EchoMemory
    let onPlayAudio: () -> Void
    let onCreateAnother: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            confirmationHeader
                .zIndex(1)

            VStack(spacing: AppSpacing.md) {
                MemoryTicketView(
                    title: echo.title,
                    date: echo.date.formatted(date: .abbreviated, time: .omitted),
                    category: echo.category.displayName,
                    accentColor: echo.category.color,
                    imageName: echo.imageName
                ) {
                    onPlayAudio()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 255)

                savedMemoryDetailsCard

                PrimaryButton(
                    "Skapa ett till minne",
                    systemImage: "plus",
                    action: onCreateAnother
                )
                .padding(.top, AppSpacing.sm)
            }
        }
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xl)
    }

    private var confirmationHeader: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.nature.opacity(0.16))
                    .frame(width: 58, height: 58)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.nature)
            }

            Text("Minnet sparat")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
        }
    }

    private var savedMemoryDetailsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "textformat")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primary)

                    Text("Titel")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()
                }

                Text(displayTitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
                .overlay(AppColors.border)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primary)

                    Text("Berättelse")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()
                }

                Text(displayStory)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
                .overlay(AppColors.border)

            Button(action: onPlayAudio) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.16))
                            .frame(width: 40, height: 40)

                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spela upp ljud")
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Lyssna på inspelningen")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "waveform")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.primary.opacity(0.8))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var displayTitle: String {
        let trimmedTitle = echo.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Ingen titel tillagd." : trimmedTitle
    }

    private var displayStory: String {
        let trimmedStory = echo.story.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStory.isEmpty ? "Ingen berättelse tillagd." : trimmedStory
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        StarBackgroundView()
            .ignoresSafeArea()

        ScrollView {
            SavedMemoryConfirmationView(
                echo: EchoMemory(
                    title: "Haag",
                    story: "Ethernet",
                    category: .nostalgic,
                    latitude: 0,
                    longitude: 0
                ),
                onPlayAudio: {},
                onCreateAnother: {}
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, 190)
        }
        .scrollIndicators(.hidden)
    }
}
