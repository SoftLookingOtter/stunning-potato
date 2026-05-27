//
//  MemoryTicketView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-27.
//

import SwiftUI

struct MemoryTicketView: View {
    let title: String
    let date: String
    let category: String
    let location: String?
    let imageName: String?
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ticketHeader

            Divider()
                .background(AppColors.border)

            ticketContent

            Divider()
                .background(AppColors.border)

            ticketFooter
        }
        .background(ticketBackground)
        .overlay(ticketBorder)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
        .padding(.horizontal, AppSpacing.lg)
    }

    private var ticketHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ECHO")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.background)

                Text("MEMORY TICKET")
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .tracking(2)
                    .foregroundStyle(AppColors.background.opacity(0.75))
            }

            Spacer()

            Text("ADMIT ONE")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1.5)
                .rotationEffect(.degrees(90))
                .foregroundStyle(AppColors.background.opacity(0.65))
                .frame(width: 70, height: 44)
        }
        .padding(AppSpacing.md)
    }

    private var ticketContent: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ticketInfo(label: "TITLE", value: title)
                ticketInfo(label: "DATE", value: date)
                ticketInfo(label: "CATEGORY", value: category)

                if let location {
                    ticketInfo(label: "LOCATION", value: location)
                }
            }

            Spacer()

            imagePlaceholder
        }
        .padding(AppSpacing.md)
    }

    private var imagePlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(AppColors.background.opacity(0.18))

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.background.opacity(0.45))
            }
        }
        .frame(width: 110, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.background.opacity(0.25), lineWidth: 1)
        )
    }

    private var ticketFooter: some View {
        HStack(spacing: AppSpacing.md) {
            waveform

            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ticketPaper)
                    .frame(width: 42, height: 42)
                    .background(AppColors.background.opacity(0.85))
                    .clipShape(Circle())
            }
        }
        .padding(AppSpacing.md)
    }

    private var waveform: some View {
        HStack(spacing: 3) {
            ForEach(0..<28, id: \.self) { index in
                Capsule()
                    .fill(AppColors.background.opacity(0.65))
                    .frame(width: 2, height: waveformHeight(for: index))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func waveformHeight(for index: Int) -> CGFloat {
        let values: [CGFloat] = [8, 14, 20, 12, 26, 18, 10, 22, 30, 16, 12, 24, 18, 28]
        return values[index % values.count]
    }

    private func ticketInfo(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .serif))
                .tracking(1.2)
                .foregroundStyle(AppColors.background.opacity(0.55))

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.background.opacity(0.88))
                .lineLimit(2)
        }
    }

    private var ticketBackground: some View {
        ticketPaper
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity(0.18),
                        .black.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var ticketBorder: some View {
        RoundedRectangle(cornerRadius: 22)
            .stroke(AppColors.background.opacity(0.25), lineWidth: 1.2)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppColors.background.opacity(0.14), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .padding(12)
            )
    }

    private var ticketPaper: Color {
        Color(red: 0.78, green: 0.64, blue: 0.42)
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        MemoryTicketView(
            title: "Mormors trädgård",
            date: "12 maj 1978",
            category: "Familjeminnen",
            location: "Gamla stan",
            imageName: nil
        ) {
            print("Play tapped")
        }
    }
}
