//
//  EchoTabIcon.swift
//  Echoes
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-09.
//

import UIKit

extension UIImage {
    static var echoTabIcon: UIImage {
        echoTabIcon(size: 26)
    }

    static func echoTabIcon(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let center = CGPoint(x: size / 2, y: size / 2)

            // Three concentric rings: small, medium, large
            let radii: [CGFloat] = [size * 0.15, size * 0.30, size * 0.45]
            for radius in radii {
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2)
                cgContext.setLineWidth(size * 0.06)
                cgContext.setStrokeColor(UIColor.white.cgColor)
                cgContext.strokeEllipse(in: rect)
            }

            // Filled center dot
            let dotRadius: CGFloat = size * 0.08
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fillEllipse(in: CGRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2))
        }
        return image.withRenderingMode(.alwaysTemplate) // lets SwiftUI tint it with .tint()
    }
}
