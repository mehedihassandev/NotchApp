import Combine
import SwiftUI

// MARK: - Music Bars Animation
/// Animated music visualization bars that pulse with playback

struct MusicBarsView: View {

    // MARK: - Properties
    let isPlaying: Bool
    let barCount: Int
    let barWidth: CGFloat
    let baseHeight: CGFloat
    let maxHeight: CGFloat
    let spacing: CGFloat
    let gradient: LinearGradient

    @State private var animationOffset: Double = 0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    // MARK: - Initialization
    init(
        isPlaying: Bool,
        barCount: Int = 3,
        barWidth: CGFloat = 3,
        baseHeight: CGFloat = 6,
        maxHeight: CGFloat = 16,
        spacing: CGFloat = 2.5,
        gradient: LinearGradient = AppTheme.Colors.musicGradient
    ) {
        self.isPlaying = isPlaying
        self.barCount = barCount
        self.barWidth = barWidth
        self.baseHeight = baseHeight
        self.maxHeight = maxHeight
        self.spacing = spacing
        self.gradient = gradient
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2, style: .continuous)
                    .fill(gradient)
                    .frame(width: barWidth, height: barHeight(for: index))
            }
        }
        .onReceive(timer) { _ in
            if isPlaying {
                animationOffset += 0.15
            }
        }
    }

    // MARK: - Helpers
    private func barHeight(for index: Int) -> CGFloat {
        guard isPlaying else { return baseHeight }

        let offset = sin(animationOffset + Double(index) * 0.8) * 0.5 + 0.5
        return baseHeight + (maxHeight - baseHeight) * offset
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            MusicBarsView(isPlaying: true)
            MusicBarsView(isPlaying: false)
        }

        HStack(spacing: 20) {
            MusicBarsView(
                isPlaying: true,
                barCount: 5,
                barWidth: 4,
                maxHeight: 24
            )

            MusicBarsView(
                isPlaying: true,
                barCount: 4,
                gradient: LinearGradient(
                    colors: [.green, .yellow],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }
    .padding()
    .background(Color.black)
}
