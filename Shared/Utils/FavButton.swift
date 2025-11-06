import SwiftUI

struct FavButton: View {
    
    @Binding var isFav: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isFav.toggle()
            }
        }) {
            Image(systemName: isFav ? "star.fill" : "star")
                .foregroundColor(isFav ? .yellow : .primary)
                .padding(4)
        }
        .buttonStyle(.bordered)
    }
}


#Preview {
    @Previewable @State var isOn = false
    FavButton(isFav: $isOn)
}
