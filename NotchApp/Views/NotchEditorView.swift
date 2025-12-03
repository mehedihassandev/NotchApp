import SwiftUI
import CoreData

struct NotchEditorView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var notch: Notch

    @State private var titleText: String = ""
    @State private var bodyText: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Title", text: $titleText)
                    .font(.title2)
                    .padding(.horizontal)

                Divider()

                TextEditor(text: $bodyText)
                    .padding()
                    .frame(minHeight: 200)

                Spacer()
            }
            .onAppear {
                titleText = notch.title ?? ""
                bodyText = notch.body ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Editor")
        }
        .onDisappear(perform: save)
    }

    func save() {
        notch.title = titleText
        notch.body = bodyText
        notch.updatedAt = Date()
        do { try context.save() } catch { print("save error:", error) }
    }
}
