import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .environment(\.managedObjectContext, context)
        } detail: {
            NotchListView()
                .environment(\.managedObjectContext, context)
        }
    }
}

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var tagVM: TagViewModel

    init() {
        // will be overridden by environment in runtime; placeholder init
        _tagVM = StateObject(wrappedValue: TagViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        VStack {
            HStack {
                Text("Collections")
                    .font(.headline)
                Spacer()
            }.padding(.horizontal)
            Divider()
            TagListView()
                .padding(.top, 8)
        }
        .onAppear {
            // update the viewmodel to use real context
            tagVM.fetchAll()
        }
    }
}
