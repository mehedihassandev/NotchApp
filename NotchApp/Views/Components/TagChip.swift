import SwiftUI

struct TagChip: View {
    @ObservedObject var tag: Tag

    var body: some View {
        Text(tag.name ?? "")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: tag.colorHex ?? "#8E8E93")))
            .foregroundColor(.white)
    }
}
