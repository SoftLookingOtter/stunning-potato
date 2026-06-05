//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-29.
//  Updated by Sara Lindén on 2026-06-05.
//

import SwiftUI
import SwiftData

struct RecordView: View {

    @Environment(\.modelContext) private var context

    @State private var viewModel = RecordViewModel()
    @State private var selectedCategory: MemoryCategory = .nostalgic

    @State private var title = ""
    @State private var story = ""
    @State private var hasApprovedRecording = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            StarBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    Text(headerTitle)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                        .animation(.easeInOut(duration: 0.2), value: headerTitle)

                    ThemePicker(
                        selectedCategory: $selectedCategory,
                        isRecording: viewModel.isRecording
                    )

                    VStack(spacing: AppSpacing.md) {
                        EchoInputField(
                            title: "Titel",
                            placeholder: "Ge minnet en titel",
                            text: $title,
                            icon: "textformat"
                        )

                        EchoInputField(
                            title: "Berättelse",
                            placeholder: "Skriv en kort berättelse",
                            text: $story,
                            icon: "quote.bubble",
                            axis: .vertical,
                            minHeight: 92
                        )
                    }

                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.people)
                            .multilineTextAlignment(.center)
                    }

                    if !hasApprovedRecording && viewModel.recordedAudioURL == nil {
                        RecordButton(isRecording: viewModel.isRecording) {
                            hasApprovedRecording = false
                            viewModel.toggleRecording()
                        }
                        .transition(.scale(scale: 0.96).combined(with: .opacity))
                    }

                    if viewModel.recordedAudioURL != nil && !viewModel.isRecording {
                        RecordingAudioBanner(
                            isApproved: hasApprovedRecording,
                            canSaveMemory: canSaveMemory,
                            isMissingTitle: isMissingTitle,
                            isMissingStory: isMissingStory,
                            onApprove: {
                                approveRecording()
                            },
                            onDiscard: {
                                discardRecording()
                            },
                            onRecordAgain: {
                                discardRecording()
                            }
                        )
                        .transition(.scale(scale: 0.96).combined(with: .opacity))
                    }

                    SaveMemoryButton(isEnabled: canSaveMemory) {
                        saveMemory()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: hasApprovedRecording)
        .animation(.easeInOut(duration: 0.2), value: canSaveMemory)
    }

    private var headerTitle: String {
        if viewModel.isRecording {
            return "Spelar in..."
        }

        if hasApprovedRecording {
            return canSaveMemory ? "Redo att spara" : "Ljud valt"
        }

        return "Börja spela in"
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedStory: String {
        story.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isMissingTitle: Bool {
        trimmedTitle.isEmpty
    }

    private var isMissingStory: Bool {
        trimmedStory.isEmpty
    }

    private var canSaveMemory: Bool {
        hasApprovedRecording &&
        viewModel.recordedAudioURL != nil &&
        !isMissingTitle &&
        !isMissingStory
    }

    private func approveRecording() {
        withAnimation {
            hasApprovedRecording = true
        }
    }

    private func discardRecording() {
        withAnimation {
            hasApprovedRecording = false
            viewModel.discardRecording()
        }
    }

    private func saveMemory() {
        guard canSaveMemory else {
            return
        }

        print("Spara minne trycktes")

        if viewModel.saveEcho(
            in: context,
            title: title,
            story: story,
            category: selectedCategory,
            latitude: 0,
            longitude: 0
        ) != nil {
            print("Echo sparad")

            title = ""
            story = ""
            hasApprovedRecording = false
            viewModel.discardRecording()
        } else {
            print("Ingen echo sparades")
        }
    }
}

// MARK: - Echo input field

private struct EchoInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var axis: Axis = .horizontal
    var minHeight: CGFloat = 52

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)

                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            TextField(placeholder, text: $text, axis: axis)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(axis == .vertical ? 5 : 1)
                .padding(AppSpacing.md)
                .frame(minHeight: minHeight, alignment: .topLeading)
                .background(AppColors.surface.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .tint(AppColors.primary)
        }
    }
}

// MARK: - Recording audio banner

private struct RecordingAudioBanner: View {
    let isApproved: Bool
    let canSaveMemory: Bool
    let isMissingTitle: Bool
    let isMissingStory: Bool
    let onApprove: () -> Void
    let onDiscard: () -> Void
    let onRecordAgain: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 38, height: 38)

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(message)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if isApproved {
                Button {
                    onRecordAgain()
                } label: {
                    Text("Spela in nytt")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.surfaceLight.opacity(0.85))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Spela in nytt ljud")
            } else {
                HStack(spacing: AppSpacing.sm) {
                    CircleIconButton(
                        systemName: "xmark",
                        foregroundColor: AppColors.people,
                        backgroundColor: AppColors.people.opacity(0.16),
                        borderColor: AppColors.people.opacity(0.45),
                        accessibilityLabel: "Kasta inspelning",
                        action: onDiscard
                    )

                    CircleIconButton(
                        systemName: "checkmark",
                        foregroundColor: AppColors.nature,
                        backgroundColor: AppColors.nature.opacity(0.16),
                        borderColor: AppColors.nature.opacity(0.45),
                        accessibilityLabel: "Behåll inspelning",
                        action: onApprove
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var title: String {
        if !isApproved {
            return "Ljud inspelat"
        }

        return canSaveMemory ? "Ljud valt – redo att spara" : "Ljud valt"
    }

    private var message: String {
        if !isApproved {
            return "Vill du behålla eller kasta inspelningen?"
        }

        if canSaveMemory {
            return "Allt är klart. Du kan spara minnet nu."
        }

        if isMissingTitle && isMissingStory {
            return "Fyll i titel och berättelse för att kunna spara minnet."
        }

        if isMissingTitle {
            return "Fyll i en titel för att kunna spara minnet."
        }

        if isMissingStory {
            return "Fyll i en berättelse för att kunna spara minnet."
        }

        return "Fyll i resten av minnet för att kunna spara."
    }

    private var iconName: String {
        if !isApproved {
            return "waveform"
        }

        return canSaveMemory ? "checkmark.seal.fill" : "checkmark"
    }

    private var iconColor: Color {
        if !isApproved {
            return AppColors.primary
        }

        return canSaveMemory ? AppColors.primary : AppColors.nature
    }

    private var backgroundColor: Color {
        if !isApproved {
            return AppColors.surface.opacity(0.88)
        }

        return canSaveMemory
        ? AppColors.primary.opacity(0.12)
        : AppColors.nature.opacity(0.10)
    }

    private var borderColor: Color {
        if !isApproved {
            return AppColors.border
        }

        return canSaveMemory
        ? AppColors.primary.opacity(0.45)
        : AppColors.nature.opacity(0.35)
    }
}

// MARK: - Save memory button

private struct SaveMemoryButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "square.and.arrow.down")

                Text("Spara minne")
                    .font(AppTypography.headline)
            }
            .foregroundStyle(isEnabled ? AppColors.primary : AppColors.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isEnabled
                ? AppColors.primary.opacity(0.12)
                : AppColors.surface.opacity(0.55)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isEnabled
                        ? AppColors.primary.opacity(0.45)
                        : AppColors.border,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.65)
    }
}

// MARK: - Circle icon button

private struct CircleIconButton: View {
    let systemName: String
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(foregroundColor)
                .frame(width: 38, height: 38)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    RecordView()
}
