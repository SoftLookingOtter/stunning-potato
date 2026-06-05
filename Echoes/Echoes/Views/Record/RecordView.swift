//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-29.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import SwiftData

struct RecordView: View {

    @Environment(\.modelContext) private var context

    @State private var viewModel = RecordViewModel()
    @State private var selectedCategory: MemoryCategory = .nostalgic

    @State private var title = ""
    @State private var story = ""

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            StarBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    Text(viewModel.isRecording ? "Spelar in..." : "Börja spela in")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)

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

                    RecordButton(isRecording: viewModel.isRecording) {
                        viewModel.toggleRecording()
                    }

                    Button {
                        print("Spara-knappen trycktes")

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
                        } else {
                            print("Ingen echo sparades")
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "square.and.arrow.down")

                            Text("Spara minne")
                                .font(AppTypography.headline)
                        }
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.primary.opacity(0.45), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl * 2)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
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
        .alert("Minne sparat!", isPresented: $ShowConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    RecordView()
}
