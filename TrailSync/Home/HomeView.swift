import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var trails: [Trail]
    @State private var showWorkoutView: Bool = false
    
    var body: some View {
        List {
            ForEach(trails) { trail in
                NavigationLink {
                    Text("Trail at \(trail.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                } label: {
                    Text(trail.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .toolbar {
            ToolbarItem(placement: .automatic) {
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
        .modelContainer(for: Trail.self, inMemory: true)
}
