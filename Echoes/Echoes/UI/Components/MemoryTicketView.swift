//
//  MemoryTicketView.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-06-06.
//  Updated by Sara Lindén on 2026-06-10.
//

import SwiftUI
import UIKit

struct MemoryTicketView: View {
    let title: String
    let date: String
    let category: String
    let accentColor: Color
    let imageName: String?
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width / 2.45
            let scale = min(max(width / 380, 0.68), 1.0)

            ticketContent(scale: scale)
                .frame(width: width, height: height)
        }
        .aspectRatio(2.45, contentMode: .fit)
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
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                ticketHeader(scale: scale)
                    .padding(.bottom, 8 * scale)

                ticketInfoSection(scale: scale)
                    .frame(width: 138 * scale, alignment: .leading)

                Spacer(minLength: 10 * scale)

                ticketFooter(scale: scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            imagePlaceholder(scale: scale)
                .padding(.top, 0)
                .padding(.trailing, 5)
        }
        .padding(.leading, 34 * scale)
        .padding(.trailing, 1 * scale)
        .padding(.top, 34 * scale)
        .padding(.bottom, 34 * scale)
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
        VStack(alignment: .leading, spacing: 6 * scale) {
            ticketInfo(label: "TITLE", value: title, scale: scale)
            ticketInfo(label: "DATE", value: date, scale: scale)
            ticketInfo(label: "CATEGORY", value: category, scale: scale)
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
                .frame(width: 105 * scale, height: 1)
                .padding(.top, 2 * scale)
        }
    }

    // MARK: - Image

    private func imagePlaceholder(scale: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4 * scale)
                .fill(AppColors.background.opacity(0.16))

            if let uiImage = loadedUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 33 * scale, weight: .medium))
                    .foregroundStyle(AppColors.background.opacity(0.45))
            }
        }
        .frame(width: 145 * scale, height: 145 * scale)
        .clipShape(RoundedRectangle(cornerRadius: 4 * scale))
        .overlay {
            RoundedRectangle(cornerRadius: 4 * scale)
                .stroke(AppColors.background.opacity(0.34), lineWidth: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 2 * scale)
                .stroke(AppColors.background.opacity(0.18), lineWidth: 1)
                .padding(5 * scale)
        }
        .clipped()
    }

    private var loadedUIImage: UIImage? {
        guard let imageName else {
            return nil
        }

        return PhotoStorageService().loadImage(named: imageName)
    }

    // MARK: - Footer

    private func ticketFooter(scale: CGFloat) -> some View {
        HStack(spacing: 12 * scale) {
            waveform(scale: scale)
                .padding(.trailing, 8 * scale)

            Button(action: onPlay) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 14 * scale)
    }

    private func waveform(scale: CGFloat) -> some View {
        GeometryReader { proxy in
            let barCount = 46
            let spacing = 3 * scale
            let availableWidth = proxy.size.width
            let barWidth = max(
                1.5,
                (availableWidth - CGFloat(barCount - 1) * spacing) / CGFloat(barCount)
            )

            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(AppColors.background.opacity(0.65))
                        .frame(
                            width: barWidth,
                            height: waveformHeight(for: index) * scale
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(height: 32 * scale)
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
                .offset(x: -11 * scale)
        }
        .frame(width: 64 * scale)
        .frame(maxHeight: .infinity)
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
        ZStack {
            ticketPaper

            accentColor
                .opacity(0.99)

            // Adds a faded, aged paper wash without fully killing the category color.
            Color(red: 0.93, green: 0.84, blue: 0.66)
                .opacity(0.18)
        }
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
                    .white.opacity(0.10),
                    .clear,
                    .black.opacity(0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
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
        .saturation(0.60)
        .brightness(0.03)
        .overlay(ticketTexture)
        .overlay(ticketDirtTexture)
    }

    private var ticketPaper: Color {
        Color(red: 0.86, green: 0.79, blue: 0.66)
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
        .allowsHitTesting(false)
    }

    private var ticketDirtTexture: some View {
        GeometryReader { proxy in
            let seed = stableSeed

            ZStack {
                // Dark stains
                ForEach(0..<24, id: \.self) { index in
                    let randomX = seededRandom(index: index, seed: seed)
                    let randomY = seededRandom(index: index + 100, seed: seed)

                    Ellipse()
                        .fill(AppColors.background.opacity(dirtOpacity(for: index, seed: seed)))
                        .frame(
                            width: randomSize(index: index, seed: seed, min: 8, max: 18),
                            height: randomSize(index: index + 31, seed: seed, min: 4, max: 10)
                        )
                        .rotationEffect(.degrees(randomDegrees(index: index, seed: seed)))
                        .position(
                            x: proxy.size.width * randomX,
                            y: proxy.size.height * randomY
                        )
                }

                // Light worn paper marks
                ForEach(0..<14, id: \.self) { index in
                    Ellipse()
                        .fill(.white.opacity(lightWearOpacity(for: index, seed: seed)))
                        .frame(
                            width: randomSize(index: index + 200, seed: seed, min: 10, max: 22),
                            height: randomSize(index: index + 240, seed: seed, min: 3, max: 8)
                        )
                        .rotationEffect(.degrees(randomDegrees(index: index + 300, seed: seed)))
                        .position(
                            x: proxy.size.width * seededRandom(index: index + 400, seed: seed),
                            y: proxy.size.height * seededRandom(index: index + 500, seed: seed)
                        )
                }

                // Scratches and paper fibers
                ForEach(0..<18, id: \.self) { index in
                    Rectangle()
                        .fill(AppColors.background.opacity(0.055))
                        .frame(
                            width: randomSize(index: index + 600, seed: seed, min: 24, max: 42),
                            height: 1
                        )
                        .rotationEffect(
                            .degrees(
                                randomDegrees(
                                    index: index + 700,
                                    seed: seed,
                                    range: 28
                                ) - 14
                            )
                        )
                        .position(
                            x: proxy.size.width * seededRandom(index: index + 800, seed: seed),
                            y: proxy.size.height * seededRandom(index: index + 900, seed: seed)
                        )
                }

                // Dark uneven edge shading
                RadialGradient(
                    colors: [
                        .clear,
                        AppColors.background.opacity(0.16)
                    ],
                    center: .center,
                    startRadius: proxy.size.width * 0.10,
                    endRadius: proxy.size.width * 0.70
                )
            }
        }
        .allowsHitTesting(false)
    }

    // Creates a stable seed so each ticket gets its own dirt pattern,
    // but the pattern does not change every time SwiftUI redraws the view.
    private var stableSeed: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(date)
        hasher.combine(category)
        return abs(hasher.finalize())
    }

    // Returns a deterministic pseudo-random value between 0 and 1.
    private func seededRandom(index: Int, seed: Int) -> CGFloat {
        let value = sin(Double(index * 12_989 + seed) * 78.233) * 43_758.5453
        let fraction = value - floor(value)
        return CGFloat(fraction)
    }

    // Returns a deterministic pseudo-random size between the given min and max.
    private func randomSize(
        index: Int,
        seed: Int,
        min: CGFloat,
        max: CGFloat
    ) -> CGFloat {
        min + seededRandom(index: index, seed: seed) * (max - min)
    }

    // Returns a deterministic pseudo-random rotation angle.
    private func randomDegrees(
        index: Int,
        seed: Int,
        range: Double = 180
    ) -> Double {
        Double(seededRandom(index: index, seed: seed)) * range
    }

    // Returns a slightly varied opacity for dark stains.
    private func dirtOpacity(for index: Int, seed: Int) -> Double {
        let baseValues: [Double] = [
            0.060, 0.085, 0.045, 0.075, 0.110,
            0.050, 0.080, 0.065, 0.095, 0.045
        ]

        let base = baseValues[index % baseValues.count]
        let variation = Double(seededRandom(index: index + 1000, seed: seed)) * 0.025

        return base + variation
    }

    // Returns a slightly varied opacity for lighter worn paper marks.
    private func lightWearOpacity(for index: Int, seed: Int) -> Double {
        let baseValues: [Double] = [
            0.035, 0.050, 0.025, 0.040, 0.060,
            0.030, 0.045, 0.035
        ]

        let base = baseValues[index % baseValues.count]
        let variation = Double(seededRandom(index: index + 1200, seed: seed)) * 0.020

        return base + variation
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

        MemoryTicketView(
            title: "Mormors trädgård",
            date: "12 maj 1978",
            category: "Familjeminnen",
            accentColor: AppColors.primary,
            imageName: nil,
            isPlaying: false
        ) {
            print("Play tapped")
        }
    }
}
