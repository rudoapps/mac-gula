//
//  RoundedCorner.swift
//  Gula
//
//  Created by Adrian Prieto Villena on 2/9/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct RoundedCorner: Shape {
    var radius: CGFloat = 6
    #if canImport(UIKit)
    var corners: UIRectCorner = .allCorners
    #else
    var corners: RectCorner = .allCorners
    #endif

    func path(in rect: CGRect) -> Path {
        #if canImport(UIKit)
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
        #else
        // macOS implementation using NSBezierPath
        var path = Path()
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        let topLeftRadius = corners.contains(.topLeft) ? radius : 0
        let topRightRadius = corners.contains(.topRight) ? radius : 0
        let bottomLeftRadius = corners.contains(.bottomLeft) ? radius : 0
        let bottomRightRadius = corners.contains(.bottomRight) ? radius : 0

        path.move(to: CGPoint(x: minX + topLeftRadius, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRightRadius, y: minY))
        if topRightRadius > 0 {
            path.addArc(center: CGPoint(x: maxX - topRightRadius, y: minY + topRightRadius),
                       radius: topRightRadius,
                       startAngle: .degrees(-90),
                       endAngle: .degrees(0),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRightRadius))
        if bottomRightRadius > 0 {
            path.addArc(center: CGPoint(x: maxX - bottomRightRadius, y: maxY - bottomRightRadius),
                       radius: bottomRightRadius,
                       startAngle: .degrees(0),
                       endAngle: .degrees(90),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: minX + bottomLeftRadius, y: maxY))
        if bottomLeftRadius > 0 {
            path.addArc(center: CGPoint(x: minX + bottomLeftRadius, y: maxY - bottomLeftRadius),
                       radius: bottomLeftRadius,
                       startAngle: .degrees(90),
                       endAngle: .degrees(180),
                       clockwise: false)
        }
        path.addLine(to: CGPoint(x: minX, y: minY + topLeftRadius))
        if topLeftRadius > 0 {
            path.addArc(center: CGPoint(x: minX + topLeftRadius, y: minY + topLeftRadius),
                       radius: topLeftRadius,
                       startAngle: .degrees(180),
                       endAngle: .degrees(270),
                       clockwise: false)
        }
        path.closeSubpath()
        return path
        #endif
    }
}

// MARK: - RectCorner for macOS
#if !canImport(UIKit)
struct RectCorner: OptionSet {
    let rawValue: Int

    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
#endif

// MARK: - Static configurations
extension RoundedCorner {
    static var standard: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: .allCorners)
        #else
        return RoundedCorner(radius: 6, corners: .allCorners)
        #endif
    }

    static var none: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 0, corners: .allCorners)
        #else
        return RoundedCorner(radius: 0, corners: .allCorners)
        #endif
    }

    static var top: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight])
        #endif
    }

    static var bottom: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight])
        #endif
    }

    static var left: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft])
        #endif
    }

    static var right: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomRight])
        #endif
    }

    static var topLeftBottomRight: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomRight])
        #endif
    }

    static var topRightBottomLeft: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft])
        #else
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft])
        #endif
    }

    static var topLeft: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: .topLeft)
        #else
        return RoundedCorner(radius: 6, corners: .topLeft)
        #endif
    }

    static var topRight: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: .topRight)
        #else
        return RoundedCorner(radius: 6, corners: .topRight)
        #endif
    }

    static var bottomLeft: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: .bottomLeft)
        #else
        return RoundedCorner(radius: 6, corners: .bottomLeft)
        #endif
    }

    static var bottomRight: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: .bottomRight)
        #else
        return RoundedCorner(radius: 6, corners: .bottomRight)
        #endif
    }

    static var allExceptTopLeft: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topRight, .bottomLeft, .bottomRight])
        #endif
    }

    static var allExceptTopRight: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .bottomLeft, .bottomRight])
        #endif
    }

    static var allExceptBottomLeft: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomRight])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomRight])
        #endif
    }

    static var allExceptBottomRight: RoundedCorner {
        #if canImport(UIKit)
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomLeft])
        #else
        return RoundedCorner(radius: 6, corners: [.topLeft, .topRight, .bottomLeft])
        #endif
    }
}

extension View {
    #if canImport(UIKit)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    #else
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    #endif
}
