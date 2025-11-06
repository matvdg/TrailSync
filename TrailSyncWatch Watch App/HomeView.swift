import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var trails: [Trail]
    @State private var showWorkoutView: Bool = false
    @State private var showActions = false
    
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
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("Add", isPresented: $showActions) {
            ForEach(WorkoutActivity.allCases) { activity in
                NavigationLink(activity.localized) {
                    activity.destinationView()
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(trails[index])
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(ModelContainer.shared)
}
