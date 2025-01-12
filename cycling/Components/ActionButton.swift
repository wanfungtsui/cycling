import SwiftUI

struct ActionButton: View {
    var title: String
    var backgroundColor: Color
    var width: CGFloat
    var action: () -> Void

    var body: some View {
        VStack {
        Button(action: action) {
            VStack {
                Text(title)
                    .bold()
                    .foregroundColor(Color.backgroundLight())
                    .frame(width: width, height: 58)
                .font(.custom("Jersey15-Regular", size: 20))
                    .background(backgroundColor)
            }
        }
    }

     .padding(.vertical, 19)

}
}
