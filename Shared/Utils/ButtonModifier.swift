import SwiftUI

struct ButtonStyleProminentModifier: ViewModifier {
    
    var isProminentForAppleWatchToo: Bool = true
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content.buttonStyle(.borderedProminent)
#elseif os(watchOS)
        if #available(watchOS 26.0, *) {
            if isProminentForAppleWatchToo {
                content.buttonStyle(.glassProminent)
            } else {
                content.buttonStyle(.plain)
            }
        } else {
            if isProminentForAppleWatchToo {
                content.buttonStyle(.borderedProminent)
            } else {
                content.buttonStyle(.plain) // false for TwelveDataPicker must be plain on watchOS
            }
        }
#elseif os(macOS)
        content.buttonStyle(.bordered)
#else
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
#endif
    }
}

struct ButtonStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content.buttonStyle(.borderedProminent)
#elseif os(watchOS)
        if #available(watchOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
#elseif os(macOS)
        content.buttonStyle(.bordered)
#else
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
#endif
    }
}
