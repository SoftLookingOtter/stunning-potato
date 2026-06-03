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

            VStack(spacing: AppSpacing.lg) {
                Text(viewModel.isRecording ? "Spelar in..." : "Börja spela in")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)

                ThemePicker(
                    selectedCategory: $selectedCategory,
                    isRecording: viewModel.isRecording
                )

                TextField("Titel", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Berättelse", text: $story, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                RecordButton(isRecording: viewModel.isRecording) {
                    viewModel.toggleRecording()
                }

                Button("Spara minne") {
                    print("Spara-knapen trycktes")

                    if viewModel.saveEcho(
                        in: context,
                        title: title,
                        story: story,
                        category: selectedCategory,
                        latitude: 0,
                        longitude: 0
                    ) != nil {
                        print("Echo Sparad")
                    } else {
                        print("Ingen echo sparades")
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

#Preview {
    RecordView()
}
