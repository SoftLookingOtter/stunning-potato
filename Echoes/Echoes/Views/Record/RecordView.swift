//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-29.
//  Updated by Sara Lindén on 2026-06-10.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct RecordView: View {

    @Environment(\.modelContext) private var context

    @State private var viewModel = RecordViewModel()
    @State private var selectedCategory: MemoryCategory = .nostalgic

    @State private var title = ""
    @State private var story = ""
    @State private var hasApprovedRecording = false

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoadingImage = false
    @State private var imageErrorMessage = ""

    @State private var savedEcho: EchoMemory?

    private let photoStorageService = PhotoStorageService()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            StarBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if let savedEcho {
                        SavedMemoryConfirmationView(
                            echo: savedEcho,
                            onPlayAudio: {
                                print("Play saved memory audio")
                                // Connect AudioPlayer/AudioService here later
                            },
                            onCreateAnother: {
                                startNewMemory()
                            }
                        )
                    } else {
                        recordingForm
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 190)
            }
            .scrollIndicators(.hidden)
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: hasApprovedRecording)
        .animation(.easeInOut(duration: 0.2), value: canSaveMemory)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: savedEcho != nil)
    }

    // MARK: - Recording form

    private var recordingForm: some View {
        VStack(spacing: AppSpacing.md) {
            Text(headerTitle)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .animation(.easeInOut(duration: 0.2), value: headerTitle)

            ThemePicker(
                selectedCategory: $selectedCategory,
                isRecording: viewModel.isRecording
            )

            VStack(spacing: AppSpacing.sm) {
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
                    minHeight: 76
                )

                ImagePickerCard(
                    selectedImageData: selectedImageData,
                    selectedPhotoItem: $selectedPhotoItem,
                    isLoadingImage: isLoadingImage,
                    errorMessage: imageErrorMessage,
                    onRemoveImage: {
                        selectedPhotoItem = nil
                        selectedImageData = nil
                        imageErrorMessage = ""
                    }
                )
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        await loadSelectedImage(from: newItem)
                    }
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.people)
                    .multilineTextAlignment(.center)
            }

            if shouldShowRecordButton {
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
                    isMissingImage: isMissingImage,
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
    }

    // MARK: - State

    private var headerTitle: String {
        if viewModel.isRecording {
            return "Spelar in..."
        }

        if hasApprovedRecording {
            return canSaveMemory ? "Redo att spara" : "Ljud valt"
        }

        return "Börja spela in"
    }

    private var shouldShowRecordButton: Bool {
        !hasApprovedRecording && viewModel.recordedAudioURL == nil
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

    private var isMissingImage: Bool {
        selectedImageData == nil
    }

    private var canSaveMemory: Bool {
        hasApprovedRecording &&
        viewModel.recordedAudioURL != nil &&
        !isMissingTitle &&
        !isMissingStory &&
        !isMissingImage
    }

    // MARK: - Actions

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

        guard let selectedImageData else {
            viewModel.errorMessage = "Du behöver lägga till en bild."
            return
        }

        print("Spara minne trycktes")

        do {
            let imageName = try photoStorageService.saveImageData(selectedImageData)

            if let echo = viewModel.saveEcho(
                in: context,
                title: title,
                story: story,
                category: selectedCategory,
                latitude: 0,
                longitude: 0,
                imageName: imageName
            ) {
                print("Echo sparad")

                savedEcho = echo

                title = ""
                story = ""
                selectedPhotoItem = nil
                self.selectedImageData = nil
                imageErrorMessage = ""
                hasApprovedRecording = false
                viewModel.clearRecordingAfterSave()
            } else {
                photoStorageService.deleteImage(named: imageName)
                print("Ingen echo sparades")
            }
        } catch {
            viewModel.errorMessage = "Bilden kunde inte sparas. Försök igen."
        }
    }

    private func startNewMemory() {
        withAnimation {
            savedEcho = nil
            title = ""
            story = ""
            selectedPhotoItem = nil
            selectedImageData = nil
            imageErrorMessage = ""
            hasApprovedRecording = false
            viewModel.errorMessage = ""
        }
    }

    @MainActor
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        selectedImageData = nil
        imageErrorMessage = ""

        guard let item else {
            return
        }

        isLoadingImage = true

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               UIImage(data: data) != nil {
                selectedImageData = data
                imageErrorMessage = ""
            } else {
                imageErrorMessage = "Bilden kunde inte läsas. Testa en annan bild."
            }
        } catch {
            imageErrorMessage = "Bilden kunde inte laddas. Om den ligger i iCloud, testa att öppna den i Bilder först."
            print("Image loading failed:", error.localizedDescription)
        }

        isLoadingImage = false
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
                .lineLimit(axis == .vertical ? 4 : 1)
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

// MARK: - Image picker card

private struct ImagePickerCard: View {
    let selectedImageData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let isLoadingImage: Bool
    let errorMessage: String
    let onRemoveImage: () -> Void

    private let imageCardHeight: CGFloat = 135

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "photo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)

                Text("Bild")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            ZStack {
                if isLoadingImage {
                    loadingImageView
                } else if let selectedImageData,
                          let uiImage = UIImage(data: selectedImageData) {
                    selectedImagePreview(uiImage)
                } else {
                    emptyImagePicker
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: imageCardHeight)
            .background(AppColors.surface.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        errorMessage.isEmpty ? AppColors.border : AppColors.people.opacity(0.45),
                        lineWidth: 1
                    )
            )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.people)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var loadingImageView: some View {
        VStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.primary)

            Text("Laddar bild...")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: imageCardHeight)
    }

    private func selectedImagePreview(_ uiImage: UIImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: imageCardHeight)
                .clipped()

            Button(action: onRemoveImage) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 30, height: 30)
                    .background(AppColors.background.opacity(0.72))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .padding(AppSpacing.sm)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ta bort bild")
        }
    }

    private var emptyImagePicker: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.14))
                        .frame(width: 38, height: 38)

                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }

                Text("Lägg till bild")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Välj en bild från biblioteket")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: imageCardHeight)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recording audio banner

private struct RecordingAudioBanner: View {
    let isApproved: Bool
    let canSaveMemory: Bool
    let isMissingTitle: Bool
    let isMissingStory: Bool
    let isMissingImage: Bool
    let onApprove: () -> Void
    let onDiscard: () -> Void
    let onRecordAgain: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 34, height: 34)

                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(message)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
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
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(AppColors.surfaceLight.opacity(0.85))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Spela in nytt ljud")
            } else {
                HStack(spacing: AppSpacing.xs) {
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
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
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

        var missingParts: [String] = []

        if isMissingTitle {
            missingParts.append("titel")
        }

        if isMissingStory {
            missingParts.append("berättelse")
        }

        if isMissingImage {
            missingParts.append("bild")
        }

        return "Fyll i \(missingParts.joined(separator: ", ")) för att kunna spara minnet."
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

// MARK: - Saved memory confirmation

private struct SavedMemoryConfirmationView: View {
    let echo: EchoMemory
    let onPlayAudio: () -> Void
    let onCreateAnother: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            confirmationHeader

            VStack(spacing: AppSpacing.lg) {
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

                savedMemoryDetailsCard

                PrimaryButton(
                    "Skapa ett till minne",
                    systemImage: "plus",
                    action: onCreateAnother
                )
            }
        }
        .padding(.top, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xl)
    }

    private var confirmationHeader: some View {
        VStack(spacing: AppSpacing.md) {
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

    private var displayStory: String {
        let trimmedStory = echo.story.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStory.isEmpty ? "Ingen berättelse tillagd." : trimmedStory
    }
}

// MARK: - Save memory button

private struct SaveMemoryButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        if isEnabled {
            PrimaryButton(
                "Spara minne",
                systemImage: "square.and.arrow.down",
                action: action
            )
        } else {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "square.and.arrow.down")

                Text("Spara minne")
                    .font(AppTypography.headline)
            }
            .foregroundStyle(AppColors.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.surface.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .opacity(0.65)
        }
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
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(foregroundColor)
                .frame(width: 34, height: 34)
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
