import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query private var trails: [Trail]
    
    @State private var showActions = false
    
    private let trailRepository = TrailRepository()
    
    var body: some View {
        
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
                            .swipeActions {
                                if #available(iOS 26, *) {
                                    Button(role: .destructive) {
                                        trailRepository.delete(trailID: trail.id, container: ModelContainer.shared)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } else {
                                    // Fallback on earlier versions
                                    Button {
                                        trailRepository.delete(trailID: trail.id, container: ModelContainer.shared)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            #if !os(watchOS)
                            .contextMenu {
                                if #available(iOS 26, *) {
                                    Button(role: .destructive) {
                                        trailRepository.delete(trailID: trail.id, container: ModelContainer.shared)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } else {
                                    // Fallback on earlier versions
                                    Button {
                                        trailRepository.delete(trailID: trail.id, container: ModelContainer.shared)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            #endif
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        
#if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
#if os(watchOS)
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "plus")
                }
#else
                Menu {
                    ForEach(WorkoutActivity.allCases) { activity in
                        NavigationLink {
                            activity.destinationView()
                        } label: {
                            Label(activity.title, systemImage: activity.iconName)
                        }
                    }
                } label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "plus")
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                    }
                }
#endif
            }
        }
        .confirmationDialog("Add", isPresented: $showActions) {
            ForEach(WorkoutActivity.allCases) { activity in
                NavigationLink(activity.localized) {
                    activity.destinationView()
                }
            }
        }
        .onAppear {
            print("ℹ️ Trails count: \(trails.count)")
        }
#endif
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Trail.self, inMemory: true)
}
