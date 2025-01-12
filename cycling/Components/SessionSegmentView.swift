import SwiftUI

struct SessionSegmentView: View {
    let segment: SessionSegment
    private let f = DateAndDurationFormatter()  // Instance of the formatter

    var body: some View {
        HStack {

            VStack {
                Text(segment.startTime, style: .time)
                .font(.custom("Jersey15-Regular", size: 20))
                    .foregroundColor(Color.backgroundLight())
                    .frame(width: 76)
                    .frame(alignment: .center)
                    .padding(.vertical, 5)
            }
            .background(Color.primaryLight())

            Text(String(format: "%.2f KM", segment.distance))
                .font(.custom("Jersey15-Regular", size: 20))
                .frame(alignment: .center)
                .foregroundColor(Color.backgroundLight())
                .background(Color.secondaryDark())
                .frame(width: 100)
                .padding(.vertical, 5)

            Text("\(String(format: "%.2f KM/H", segment.averageSpeed))")
                .font(.custom("Jersey15-Regular", size: 20))
                .frame(alignment: .center)
                .foregroundColor(Color.backgroundLight())
                .background(Color.secondaryDark())
                .frame(width: 150)
                .padding(.vertical, 5)

        }
        .frame(width: 326)
        .background(Color.secondaryDark())
    }
}

