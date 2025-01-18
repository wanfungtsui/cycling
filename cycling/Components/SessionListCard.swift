import SwiftUI

struct SessionListCard: View {
    let session: SessionSummary
    let formatter: DateAndDurationFormatter
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(formatter.formattedDate(session.date))
                    .foregroundColor(Color.backgroundLight())
                    .font(.custom("Jersey15-Regular", size: 20))
            }
            HStack {
                Text("Total Distance")
                    .foregroundColor(Color.textDark())
                    .font(.custom("Jersey15-Regular", size: 15))
                Spacer()
                Text(String(format: "%.2f km", session.totalDistance))
                    .foregroundColor(Color.backgroundLight())
                    .font(.custom("Jersey15-Regular", size: 25))
            }

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .foregroundColor(Color.textDark())
                        .font(.custom("Jersey15-Regular", size: 15))
                    Text(formatter.formatDuration(session.totalDuration))
                        .foregroundColor(Color.backgroundLight())
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Avg Speed")
                        .foregroundColor(Color.textDark())
                        .font(.custom("Jersey15-Regular", size: 15))
                    Text(String(format: "%.1f km/h", session.averageSpeed))
                        .foregroundColor(Color.backgroundLight())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Calories")
                        .foregroundColor(Color.textDark())
                        .font(.custom("Jersey15-Regular", size: 15))
                    Text(String(format: "%.0f kcal", session.totalCalories))
                        .foregroundColor(Color.backgroundLight())
                }
            }
            Text("\(session.segments.count) segments")
                .foregroundColor(Color.backgroundLight())
                .font(.custom("Jersey15-Regular", size: 15))
        }

        .padding()
        .background(backgroundColor)
        .cornerRadius(10)

    }
} 
