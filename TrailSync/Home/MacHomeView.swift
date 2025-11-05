import SwiftUI
import SwiftData

struct MacHomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var trails: [Trail]

    var body: some View {
        NavigationSplitView {
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
        } detail: {
            Text("Select")
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
    MacHomeView()
        .modelContainer(for: Trail.self, inMemory: true)
}
