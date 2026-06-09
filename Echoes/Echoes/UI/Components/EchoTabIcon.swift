//
//  EchoTabIcon.swift
//  Echoes
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-09.
//

import UIKit

extension UI Image {
    static func echoTabIcon(size: CGFloat = 26) -> UIImage {
        CGSize(width: size, height: size))
        return renderer.image { context in
            let cgContext = context.cgContext}
        let center = CGPoint(x: size / 2, y: size / 2)
        
        // Three concentric rings: small, medium, large
        
        let raddii: [CGFloat] = [size * 0.15, size * 0.30, size * 0,45]
        for radius in radii {
            let rect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2)
            cgContext.setLineWidth(size * 0.06)
            
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.strokeEllipse( in: rect)
        }
        
        // Filled center dot
        let dotRadius: CGFloat = size * 0.8
        CGContext.setFillColor(UI.white.cgColor)
        cgContext.fillEllipse(self: CGRect(
            x: center.x - dotRadius,
            y: center.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2))
        
    }
        .withRenderingMode(.alwaysTemplate) // lets SwiftUI tint it with .tint()
}
