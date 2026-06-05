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
        ticketContent(scale: 1)
            .aspectRatio(1.72, contentMode: .fit)
    }

    private func ticketContent(scale: CGFloat) -> some View {
        let ticketShape = TicketShape(
            cornerRadius: 12 * scale,
            bigNotchRadius: 13 * scale,
            bigNotchYOffset: 0.25,
            smallNotchRadius: 2.0 * scale,
            smallNotchDepth: 2.9 * scale,
            smallNotchCountAbove: 2,
            smallNotchCountBelow: 10
        )

        return HStack(spacing: 0) {
            mainTicketContent(scale: scale)

            perforationLine(scale: scale)

            admitOneStrip(scale: scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ticketBackground)
        .overlay(ticketInnerBorder(scale: scale))
        .clipShape(ticketShape)
        .contentShape(ticketShape)
        .shadow(
            color: .black.opacity(0.28),
            radius: 14,
            x: 0,
            y: 8
        )
    }

    // MARK: - Main content

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
        .padding(.leading, 26 * scale)
        .padding(.trailing, 18 * scale)
        .padding(.top, 24 * scale)
        .padding(.bottom, 20 * scale)
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

    private func ticketInfo(label: String, value: String, scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 2 * scale) {
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

            Rectangle()
                .fill(AppColors.background.opacity(0.18))
                .frame(height: 1)
                .padding(.top, 2 * scale)
        }
    }

    // MARK: - Image

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
        .clipShape(RoundedRectangle(cornerRadius: 7 * scale))
        .overlay {
            RoundedRectangle(cornerRadius: 7 * scale)
                .stroke(AppColors.background.opacity(0.24), lineWidth: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 3 * scale)
                .stroke(AppColors.background.opacity(0.16), lineWidth: 1)
                .padding(4 * scale)
        }
        .clipped()
    }

    // MARK: - Footer

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
                    .overlay {
                        Circle()
                            .stroke(AppColors.background.opacity(0.18), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
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

    private func waveformHeight(for index: Int) -> CGFloat {
        let values: [CGFloat] = [
            8, 13, 18, 10, 22, 15, 9, 19, 25,
            14, 11, 20, 16, 12, 23, 17, 9
        ]

        return values[index % values.count]
    }

    // MARK: - Admit one strip

    private func admitOneStrip(scale: CGFloat) -> some View {
        ZStack {
            Text("ADMIT ONE")
                .font(.system(size: 15 * scale, weight: .bold, design: .serif))
                .tracking(1.6 * scale)
                .foregroundStyle(AppColors.background.opacity(0.82))
                .rotationEffect(.degrees(-90))
                .frame(width: 124 * scale, height: 30 * scale)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 64 * scale)
        .frame(maxHeight: .infinity)
        .padding(.trailing, 6 * scale)
    }

    private func perforationLine(scale: CGFloat) -> some View {
        DashedVerticalLine()
            .stroke(
                AppColors.background.opacity(0.28),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: [4 * scale, 4 * scale]
                )
            )
            .frame(width: 1)
            .padding(.vertical, 26 * scale)
    }

    // MARK: - Border

    private func ticketInnerBorder(scale: CGFloat) -> some View {
        ZStack {
            TicketInsetBorder(
                inset: 18 * scale,
                cornerRadius: 12 * scale
            )
            .stroke(AppColors.background.opacity(0.26), lineWidth: 1)

            TicketInsetBorder(
                inset: 22 * scale,
                cornerRadius: 10 * scale
            )
            .stroke(AppColors.background.opacity(0.16), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Background

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
            .overlay(
                LinearGradient(
                    colors: [
                        .black.opacity(0.10),
                        .clear,
                        .black.opacity(0.10)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(ticketTexture)
    }

    private var ticketPaper: Color {
        ticketPaperColor(for: category)
    }

    private func ticketPaperColor(for category: String) -> Color {
        let normalizedCategory = category
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch normalizedCategory {
        case "familjeminnen", "family", "family memories":
            return Color(red: 0.78, green: 0.64, blue: 0.42)

        case "nostalgi", "nostalgia":
            return Color(red: 0.55, green: 0.58, blue: 0.39)

        case "mystik", "mystery":
            return Color(red: 0.50, green: 0.38, blue: 0.42)

        case "historia", "history":
            return Color(red: 0.52, green: 0.45, blue: 0.34)

        case "events", "event", "händelser":
            return Color(red: 0.45, green: 0.50, blue: 0.58)

        case "calm", "lugn":
            return Color(red: 0.48, green: 0.58, blue: 0.54)

        default:
            return Color(red: 0.78, green: 0.64, blue: 0.42)
        }
    }

    private var ticketTexture: some View {
        GeometryReader { proxy in
            ForEach(0..<34, id: \.self) { index in
                Circle()
                    .fill(AppColors.background.opacity(0.075))
                    .frame(
                        width: CGFloat((index % 4) + 2),
                        height: CGFloat((index % 4) + 2)
                    )
                    .position(
                        x: proxy.size.width * CGFloat((index * 37) % 100) / 100,
                        y: proxy.size.height * CGFloat((index * 61) % 100) / 100
                    )
            }
        }
    }
}

// MARK: - Ticket shape

struct TicketShape: Shape {
    var cornerRadius: CGFloat = 12
    var bigNotchRadius: CGFloat = 13
    var bigNotchYOffset: CGFloat = 0.25

    var smallNotchRadius: CGFloat = 1.6
    var smallNotchDepth: CGFloat = 1.4

    var smallNotchCountAbove: Int = 2
    var smallNotchCountBelow: Int = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY
        let bigCenterY = minY + rect.height * bigNotchYOffset

        path.move(to: CGPoint(x: minX + cornerRadius, y: minY))

        path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))

        path.addArc(
            center: CGPoint(x: maxX, y: minY),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )

        addRightNotchedEdge(
            path: &path,
            x: maxX,
            fromY: minY + cornerRadius,
            toY: bigCenterY - bigNotchRadius,
            count: smallNotchCountAbove
        )

        path.addArc(
            center: CGPoint(x: maxX, y: bigCenterY),
            radius: bigNotchRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )

        addRightNotchedEdge(
            path: &path,
            x: maxX,
            fromY: bigCenterY + bigNotchRadius,
            toY: maxY - cornerRadius,
            count: smallNotchCountBelow
        )

        path.addArc(
            center: CGPoint(x: maxX, y: maxY),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(180),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: minX + cornerRadius, y: maxY))

        path.addArc(
            center: CGPoint(x: minX, y: maxY),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(270),
            clockwise: true
        )

        addLeftNotchedEdge(
            path: &path,
            x: minX,
            fromY: maxY - cornerRadius,
            toY: bigCenterY + bigNotchRadius,
            count: smallNotchCountBelow
        )

        path.addArc(
            center: CGPoint(x: minX, y: bigCenterY),
            radius: bigNotchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )

        addLeftNotchedEdge(
            path: &path,
            x: minX,
            fromY: bigCenterY - bigNotchRadius,
            toY: minY + cornerRadius,
            count: smallNotchCountAbove
        )

        path.addArc(
            center: CGPoint(x: minX, y: minY),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )

        path.closeSubpath()
        return path
    }

    private func addRightNotchedEdge(
        path: inout Path,
        x: CGFloat,
        fromY: CGFloat,
        toY: CGFloat,
        count: Int
    ) {
        guard count > 0, toY > fromY else {
            path.addLine(to: CGPoint(x: x, y: toY))
            return
        }

        let spacing = (toY - fromY) / CGFloat(count + 1)

        for index in 1...count {
            let centerY = fromY + CGFloat(index) * spacing

            path.addLine(to: CGPoint(x: x, y: centerY - smallNotchRadius))
            path.addQuadCurve(
                to: CGPoint(x: x, y: centerY + smallNotchRadius),
                control: CGPoint(x: x - smallNotchDepth, y: centerY)
            )
        }

        path.addLine(to: CGPoint(x: x, y: toY))
    }

    private func addLeftNotchedEdge(
        path: inout Path,
        x: CGFloat,
        fromY: CGFloat,
        toY: CGFloat,
        count: Int
    ) {
        guard count > 0, fromY > toY else {
            path.addLine(to: CGPoint(x: x, y: toY))
            return
        }

        let spacing = (fromY - toY) / CGFloat(count + 1)

        for index in 1...count {
            let centerY = fromY - CGFloat(index) * spacing

            path.addLine(to: CGPoint(x: x, y: centerY + smallNotchRadius))
            path.addQuadCurve(
                to: CGPoint(x: x, y: centerY - smallNotchRadius),
                control: CGPoint(x: x + smallNotchDepth, y: centerY)
            )
        }

        path.addLine(to: CGPoint(x: x, y: toY))
    }
}

// MARK: - Decorative shapes

struct DashedVerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct TicketInsetBorder: Shape {
    var inset: CGFloat = 12
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let insetRect = rect.insetBy(dx: inset, dy: inset)

        let minX = insetRect.minX
        let maxX = insetRect.maxX
        let minY = insetRect.minY
        let maxY = insetRect.maxY

        let radius = min(
            cornerRadius,
            insetRect.width * 0.12,
            insetRect.height * 0.24
        )

        path.move(to: CGPoint(x: minX + radius, y: minY))

        path.addLine(to: CGPoint(x: maxX - radius, y: minY))

        path.addArc(
            center: CGPoint(x: maxX, y: minY),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: maxX, y: maxY - radius))

        path.addArc(
            center: CGPoint(x: maxX, y: maxY),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(180),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: minX + radius, y: maxY))

        path.addArc(
            center: CGPoint(x: minX, y: maxY),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(270),
            clockwise: true
        )

        path.addLine(to: CGPoint(x: minX, y: minY + radius))

        path.addArc(
            center: CGPoint(x: minX, y: minY),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 24) {
                MemoryTicketView(
                    title: "Mormors trädgård",
                    date: "12 maj 1978",
                    category: "Familjeminnen",
                    location: "Gamla stan",
                    imageName: nil
                ) {
                    print("Play tapped")
                }

                MemoryTicketView(
                    title: "Gamla cykelverkstaden",
                    date: "3 juni 1952",
                    category: "Nostalgi",
                    location: "Cykelverkstaden",
                    imageName: nil
                ) {
                    print("Play tapped")
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.xl)
        }
    }
}
