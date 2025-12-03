import SwiftUI
import CoreData
import Combine

struct NotchListView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm: NotchListViewModel

    @State private var selectedNotch: Notch?
    @State private var showEditor = false

    init() {
        _vm = StateObject(wrappedValue: NotchListViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        VStack {
            HStack {
                Text("Notches")
                    .font(.title2)
                Spacer()
                Button(action: newNotch) {
                    Label("New", systemImage: "plus")
                }
            }.padding(.horizontal)

            List {
                ForEach(vm.notches, id: \.id) { notch in
                    NotchCardView(notch: notch)
                        .onTapGesture {
                            selectedNotch = notch
                        }
                }
                .onDelete(perform: vm.delete)
            }
        }
        .sheet(item: $selectedNotch) { notch in
            NotchEditorView(notch: notch)
                .environment(\.managedObjectContext, context)
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewNotch)) { _ in
            selectedNotch = vm.create()
        }
        .onAppear {
            vm.context = context
            vm.fetchAll()
        }
    }

    func newNotch() {
        selectedNotch = vm.create()
    }
}

final class NotchListViewModel: ObservableObject {
    var context: NSManagedObjectContext
    @Published var notches: [Notch] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAll()
    }

    func fetchAll() {
        let req: NSFetchRequest<Notch> = Notch.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        do {
            notches = try context.fetch(req)
        } catch {
            print("fetch all notches error:", error)
            notches = []
        }
    }

    func create() -> Notch {
        let n = Notch(context: context, title: "", body: "")
        save()
        fetchAll()
        return n
    }

    func delete(at offsets: IndexSet) {
        offsets.map { notches[$0] }.forEach(context.delete)
        save()
        fetchAll()
    }

    func save() {
        do { try context.save() } catch { print("save error:", error) }
    }
}
