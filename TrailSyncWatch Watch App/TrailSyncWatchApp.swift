import SwiftUI
import SwiftData

@main
struct TrailSyncWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .modelContainer(ModelContainer.shared)
            }
        }
    }
}
