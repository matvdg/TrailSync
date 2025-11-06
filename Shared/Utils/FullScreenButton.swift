import SwiftUI

struct FullScreenButton: View {
    
    @Binding var isFullscreen: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isFullscreen.toggle()
            }
        }) {
            Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                .padding(4)
        }
        .buttonStyle(.bordered)
    }
}


#Preview {
    @Previewable @State var isOn = false
    FullScreenButton(isFullscreen: $isOn)
}
