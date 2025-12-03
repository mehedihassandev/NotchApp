import SwiftUI

struct NotchCardView: View {
    @ObservedObject var notch: Notch

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let t = notch.title, !t.isEmpty {
                Text(t).font(.headline)
            } else {
                Text(notch.body ?? "").lineLimit(2).font(.headline)
            }
            Text(snippet).font(.subheadline).foregroundColor(.secondary)
            HStack {
                ForEach(notch.tagArray, id: \.id) { tag in
                    TagChip(tag: tag)
                }
                Spacer()
                if notch.pinned {
                    Image(systemName: "pin.fill")
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemFill)))
    }

    var snippet: String {
        let s = notch.body ?? ""
        return s.count > 120 ? String(s.prefix(120)) + "…" : s
    }
}
