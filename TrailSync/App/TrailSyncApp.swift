#if os(iOS)
import UIKit
#endif
import SwiftUI
import SwiftData

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    var sceneDelegate: SceneDelegate?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    /// Shared QuickActionCoordinator instance to track the launched QuickAction
    static var quickActionCoordinator = QuickActionCoordinator()
    
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        SceneDelegate.quickActionCoordinator.launchedQuickAction = WorkoutActivity(rawValue: shortcutItem.type)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            // Convert the ShortcutItem into a QuickAction and store it as the launchedQuickAction
            handleShortcutItem(shortcutItem)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Update the launchedQuickAction while the app is already running
        handleShortcutItem(shortcutItem)
        completionHandler(true)
    }
}
#endif


@main
struct TrailSyncApp: App {
    
#if os(iOS)
    // On iOS, handle Quick Actions via AppDelegate and SceneDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// QuickActionCoordinator is @Observable, so SwiftUI automatically refreshes
    /// when SceneDelegate updates the launchedQuickAction.
    @State private var quickActionCoordinator = SceneDelegate.quickActionCoordinator
#endif
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            NavigationSplitView {
                HomeView()
            } detail: {
                Label("SelectInSidebar", systemImage: "sidebar.left")
            }
#else
            NavigationSplitView {
                HomeView()
                #if os(iOS)
                    .navigationDestination(item: $quickActionCoordinator.launchedQuickAction) { shortcut in
                        shortcut.destinationView()
                    }
                    .onChange(of: scenePhase) {
                        UIApplication.shared.shortcutItems = WorkoutActivity.allCases.map { $0.shortcutItem }
                    }
                #endif
            } detail: {
                Label("SelectInSidebar", systemImage: "sidebar.left")
            }
#endif
        }
        .modelContainer(ModelContainer.shared)
    }
    
}

@Observable
class QuickActionCoordinator {
    
    var launchedQuickAction: WorkoutActivity?
    
}
