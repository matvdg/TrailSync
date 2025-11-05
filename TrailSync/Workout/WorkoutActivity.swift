import SwiftUI
import HealthKit

enum WorkoutActivity: String, Identifiable, CaseIterable, Equatable {
    
    case hiking, walking, running, cycling
    
    var id: String { rawValue }
    var title: String { NSLocalizedString(rawValue.capitalized, comment: "") }
    var localized: LocalizedStringKey { LocalizedStringKey(rawValue.capitalized) }
    
    #if os(iOS)
    var shortcutItem: UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: iconName),
            userInfo: nil
        )
    }
    #endif
    
    @ViewBuilder
    func destinationView() -> some View {
        WorkoutView(workoutActivity: self)
    }
    
    var icon: Image { Image(systemName: iconName) }
    
    var iconName: String {
        switch self {
        case .hiking: return "figure.hiking"
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        }
    }
    
    var activity: HKWorkoutActivityType {
        switch self {
        case .hiking: return .hiking
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        }
    }
    
    static func activity(from: HKWorkoutActivityType) -> WorkoutActivity {
        switch from {
        case .hiking: return .hiking
        case .walking: return .walking
        case .running: return .running
        default: return .cycling
        }
    }
}
