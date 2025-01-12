import SwiftUI

struct CardView: View {
    var backgroundColor: Color
    var cardName: String
    var metric: String
    var unit: String

    var body: some View {
        VStack(spacing: 10) {

            HStack {
                Text(cardName)
                .font(.custom("Jersey15-Regular", size: 20))
                    .foregroundColor(Color.textDark())
                    .padding(.vertical, 10)

            }

            HStack(alignment: .top) {
                Text(metric)
                .font(.custom("Jersey15-Regular", size: 40))
                    .bold()
                    .foregroundColor(Color.textDark())
                    .frame(alignment: .center)

                Text(unit)
                .font(.custom("Jersey15-Regular", size: 15))
                    .foregroundColor(Color.textLight())

            }.padding(.bottom, 10)

        }
        .frame(width: 300)
        .background(Color.backgroundLight())
        .border(Color.textDark(), width: 2)
    }
}