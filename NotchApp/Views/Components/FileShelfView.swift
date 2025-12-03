import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct FileShelfView: View {
    @State private var files: [URL] = []
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Shelf")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if files.isEmpty {
                        emptyState
                    } else {
                        ForEach(files, id: \.self) { url in
                            FileItemView(url: url) {
                                if let index = files.firstIndex(of: url) {
                                    files.remove(at: index)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.25))
            )
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                loadFiles(from: providers)
                return true
            }
        }
    }

    private var emptyState: some View {
        HStack {
            Image(systemName: "tray.and.arrow.down")
                .font(.system(size: 24))
                .foregroundColor(isTargeted ? .white : .secondary)

            Text(isTargeted ? "Drop to Add" : "Drop Files Here")
                .font(.subheadline)
                .foregroundColor(isTargeted ? .white : .secondary)
        }
        .frame(width: 200, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(isTargeted ? .white.opacity(0.5) : .white.opacity(0.1))
        )
    }

    private func loadFiles(from providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            if !files.contains(url) {
                                files.append(url)
                            }
                        }
                    } else if let url = item as? URL {
                        DispatchQueue.main.async {
                            if !files.contains(url) {
                                files.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FileItemView: View {
    let url: URL
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)

                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .background(Circle().fill(Color.white))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 5, y: -5)
                }
            }

            Text(url.lastPathComponent)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            NSWorkspace.shared.open(url)
        }
    }
}
