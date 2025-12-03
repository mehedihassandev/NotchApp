import SwiftUI

struct DashboardView: View {
    @ObservedObject var mediaManager: MediaPlayerManager

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Media Widget
                MediaDisplayView(
                    mediaInfo: mediaManager.currentMedia,
                    onPlayPause: {
                        mediaManager.togglePlayPause()
                    },
                    onPrevious: {
                        mediaManager.previousTrack()
                    },
                    onNext: {
                        mediaManager.nextTrack()
                    }
                )

                // Live Actions Grid
                LiveActionsView()

                // File Shelf
                FileShelfView()
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .frame(maxHeight: 500)
    }
}
