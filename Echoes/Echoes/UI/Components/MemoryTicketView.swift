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
        GeometryReader { proxy in
            let width = proxy.size.width
            let scale = min(max(width / 360, 0.78), 1.12)

            HStack(spacing: 0) {
                mainTicketContent(scale: scale)

                admitOneStrip(scale: scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ticketBackground)
            .overlay(ticketBorder(scale: scale))
            .clipShape(
                TicketShape(
                    cornerRadius: 18 * scale,
                    notchRadius: 13 * scale
                )
            )
            .shadow(
                color: .black.opacity(0.28),
                radius: 14,
                x: 0,
                y: 8
            )
        }
        .aspectRatio(1.72, contentMode: .fit)
        .padding(.horizontal, AppSpacing.xl)
    }

    private func mainTicketContent(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            ticketHeader(scale: scale)

            HStack(alignment: .top, spacing: 14 * scale) {
                ticketInfoSection(scale: scale)

                Spacer(minLength: 8 * scale)

                imagePlaceholder(scale: scale)
            }

            Spacer(minLength: 6 * scale)

            ticketFooter(scale: scale)
        }
        .padding(.leading, 20 * scale)
        .padding(.trailing, 14 * scale)
        .padding(.top, 18 * scale)
        .padding(.bottom, 16 * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func ticketHeader(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ECHO")
                .font(.system(size: 24 * scale, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.background)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("MEMORY TICKET")
                .font(.system(size: 9 * scale, weight: .semibold, design: .serif))
                .tracking(1.8 * scale)
                .foregroundStyle(AppColors.background.opacity(0.72))
                .lineLimit(1)
        }
    }

    private func ticketInfoSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5 * scale) {
            ticketInfo(label: "TITLE", value: title, scale: scale)
            ticketInfo(label: "DATE", value: date, scale: scale)
            ticketInfo(label: "CATEGORY", value: category, scale: scale)

            if let location {
                ticketInfo(label: "LOCATION", value: location, scale: scale)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func imagePlaceholder(scale: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(AppColors.background.opacity(0.18))

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 24 * scale, weight: .medium))
                    .foregroundStyle(AppColors.background.opacity(0.45))
            }
        }
        .frame(width: 112 * scale, height: 82 * scale)
        .clipShape(RoundedRectangle(cornerRadius: 9 * scale))
        .overlay(
            RoundedRectangle(cornerRadius: 9 * scale)
                .stroke(AppColors.background.opacity(0.25), lineWidth: 1)
        )
    }

    private func ticketFooter(scale: CGFloat) -> some View {
        HStack(spacing: 12 * scale) {
            waveform(scale: scale)

            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.system(size: 13 * scale, weight: .bold))
                    .foregroundStyle(ticketPaper)
                    .frame(width: 32 * scale, height: 32 * scale)
                    .background(AppColors.background.opacity(0.88))
                    .clipShape(Circle())
            }
            .padding(.trailing, 10 * scale)
        }
    }

    private func waveform(scale: CGFloat) -> some View {
        HStack(spacing: 3 * scale) {
            ForEach(0..<34, id: \.self) { index in
                Capsule()
                    .fill(AppColors.background.opacity(0.65))
                    .frame(
                        width: max(1.5, 2 * scale),
                        height: waveformHeight(for: index) * scale
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func admitOneStrip(scale: CGFloat) -> some View {
        VStack {
            Spacer(minLength: 22 * scale)

            Text("ADMIT ONE")
                .font(.system(size: 9.5 * scale, weight: .bold, design: .serif))
                .tracking(1.1 * scale)
                .foregroundStyle(AppColors.background.opacity(0.68))
                .rotationEffect(.degrees(90))
                .frame(width: 112 * scale, height: 44 * scale)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()
        }
        .frame(width: 58 * scale)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .leading) {
            Rectangle()
                .stroke(
                    AppColors.background.opacity(0.30),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                )
                .frame(width: 1)
        }
        .padding(.trailing, 6 * scale)
    }

    private func waveformHeight(for index: Int) -> CGFloat {
        let values: [CGFloat] = [8, 13, 18, 10, 22, 15, 9, 19, 25, 14, 11, 20, 16, 12, 23, 17, 9]
        return values[index % values.count]
    }

    private func ticketInfo(label: String, value: String, scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 8 * scale, weight: .bold, design: .serif))
                .tracking(1.2 * scale)
                .foregroundStyle(AppColors.background.opacity(0.55))
                .lineLimit(1)

            Text(value)
                .font(.system(size: 13 * scale, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.background.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
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

    private func ticketBorder(scale: CGFloat) -> some View {
        TicketShape(
            cornerRadius: 18 * scale,
            notchRadius: 13 * scale
        )
        .stroke(AppColors.background.opacity(0.28), lineWidth: 1.2)
        .padding(5 * scale)
        .overlay(
            TicketShape(
                cornerRadius: 15 * scale,
                notchRadius: 10 * scale
            )
            .stroke(
                AppColors.background.opacity(0.18),
                style: StrokeStyle(lineWidth: 1, dash: [6, 4])
            )
            .padding(13 * scale)
        )
    }

    private var ticketPaper: Color {
        Color(red: 0.78, green: 0.64, blue: 0.42)
    }
}

struct TicketShape: Shape {
    var cornerRadius: CGFloat = 18
    var notchRadius: CGFloat = 13

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY
        let midY = rect.midY

        path.move(to: CGPoint(x: minX + cornerRadius, y: minY))

        path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
        path.addQuadCurve(
            to: CGPoint(x: maxX, y: minY + cornerRadius),
            control: CGPoint(x: maxX, y: minY)
        )

        path.addLine(to: CGPoint(x: maxX, y: midY - notchRadius))
        path.addArc(
            center: CGPoint(x: maxX, y: midY),
            radius: notchRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: maxX - cornerRadius, y: maxY),
            control: CGPoint(x: maxX, y: maxY)
        )

        path.addLine(to: CGPoint(x: minX + cornerRadius, y: maxY))
        path.addQuadCurve(
            to: CGPoint(x: minX, y: maxY - cornerRadius),
            control: CGPoint(x: minX, y: maxY)
        )

        path.addLine(to: CGPoint(x: minX, y: midY + notchRadius))
        path.addArc(
            center: CGPoint(x: minX, y: midY),
            radius: notchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: minX, y: minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: minX + cornerRadius, y: minY),
            control: CGPoint(x: minX, y: minY)
        )

        path.closeSubpath()

        return path
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
