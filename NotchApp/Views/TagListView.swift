import SwiftUI
import CoreData

struct TagListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Tag.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) private var tags: FetchedResults<Tag>

    @State private var newTagName = ""

    var body: some View {
        VStack {
            HStack {
                TextField("New tag", text: $newTagName)
                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                }
            }.padding(.horizontal)

            List {
                ForEach(tags, id: \.id) { tag in
                    HStack {
                        TagChip(tag: tag)
                        Text(tag.name ?? "Unnamed")
                        Spacer()
                    }
                }.onDelete(perform: delete)
            }
        }
    }

    func addTag() {
        guard !newTagName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        _ = Tag(context: context, name: newTagName, colorHex: "#4184F4")
        do { try context.save(); newTagName = "" } catch { print("tag save error:", error) }
    }

    func delete(at offsets: IndexSet) {
        offsets.map { tags[$0] }.forEach(context.delete)
        try? context.save()
    }
}
