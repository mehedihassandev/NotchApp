import SwiftUI

// MARK: - Notch Shape
/// Custom MacBook-style notch shape with sharp top corners and rounded bottom corners
/// Used as the main container shape for the notch interface

struct NotchShape: Shape {

    // MARK: - Properties
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    // MARK: - Initialization
    init(topCornerRadius: CGFloat = 0, bottomCornerRadius: CGFloat = 16) {
        self.topCornerRadius = topCornerRadius
        self.bottomCornerRadius = bottomCornerRadius
    }

    // MARK: - Shape Implementation
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let bottomRadius = bottomCornerRadius

        // Start from top-left (sharp corner)
        path.move(to: CGPoint(x: 0, y: 0))

        // Top edge (straight line, sharp corners)
        path.addLine(to: CGPoint(x: width, y: 0))

        // Right edge down to bottom corner
        path.addLine(to: CGPoint(x: width, y: height - bottomRadius))

        // Bottom-right corner (rounded)
        path.addArc(
            center: CGPoint(x: width - bottomRadius, y: height - bottomRadius),
            radius: bottomRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: bottomRadius, y: height))

        // Bottom-left corner (rounded)
        path.addArc(
            center: CGPoint(x: bottomRadius, y: height - bottomRadius),
            radius: bottomRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge up to top (sharp corner)
        path.addLine(to: CGPoint(x: 0, y: 0))

        path.closeSubpath()

        return path
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        NotchShape(topCornerRadius: 0, bottomCornerRadius: 16)
            .fill(Color.black)
            .frame(width: 200, height: 60)

        NotchShape(topCornerRadius: 0, bottomCornerRadius: 20)
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: 300, height: 100)
    }
    .padding()
}
