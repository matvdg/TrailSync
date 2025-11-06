import SwiftUI
import SwiftData

struct MacHomeView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var trails: [Trail]
    
    private let trailRepository = TrailRepository()

    var body: some View {
        NavigationSplitView {
            Group {
                if trails.isEmpty {
                    VStack {
                        ContentUnavailableView(
                            "EmptyTrailsTitle",
                            systemImage: "signpost.right.and.left",
                            description: Text("EmptyTrailsDescription")
                        )
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(trails) { trail in
                            NavigationLink {
                                TrailView(trail: trail)
                            } label: {
                                TrailRow(trail: trail)
                            }
                            .contextMenu {
                                if #available(iOS 26, *) {
                                    Button(role: .destructive) {
                                        trailRepository.delete(trail: trail, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } else {
                                    // Fallback on earlier versions
                                    Button {
                                        trailRepository.delete(trail: trail, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Label("SelectInSidebar", systemImage: "sidebar.left")
        }
    }
}

#Preview {
    MacHomeView()
        .modelContainer(for: Trail.self, inMemory: true)
}
