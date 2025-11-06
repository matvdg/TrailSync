#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

enum Feedback {
    case success
    case error
    case selectionChanged

    @MainActor
    func play() {
#if os(macOS)
        // Do nothing
#elseif os(iOS)
        if self == .selectionChanged {
            UISelectionFeedbackGenerator().selectionChanged()
        } else {
            let feedbackType: UINotificationFeedbackGenerator.FeedbackType
            switch self {
            case .success:
                feedbackType = .success
            default:
                feedbackType = .error
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(feedbackType)
            }
        }
#elseif os(watchOS)
        let hapticType: WKHapticType
        switch self {
        case .success:
            hapticType = .success
        case .error:
            hapticType = .failure
        case .selectionChanged:
            hapticType = .click
        }
        WKInterfaceDevice.current().play(hapticType)
#endif
    }
}
