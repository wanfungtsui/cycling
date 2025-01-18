import MapKit
import SwiftUI

struct SessionDetailView: View {
    let session: SessionSummary
    let f = DateAndDurationFormatter()  // Instance of the formatter

    var body: some View {
        ZStack {
            Color.backgroundLight()  // Set the background color for the entire view
                .edgesIgnoringSafeArea(.all)  // Ensure it covers the entire screen
            ScrollView {
                VStack(spacing: 20) {
                    // Map View for Route
                    HStack {
                        Text("Details")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(Color.textLight())
                            .frame(alignment: .center)
                    }

                    VStack(spacing: 20) {
                        // Session Summary Card
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(session.date, style: .date).font(
                                    .custom("Jersey15-Regular", size: 20)
                                ).foregroundColor(Color.textDark())

                                Spacer()
                                Text(session.date, style: .time).font(
                                    .custom("Jersey15-Regular", size: 20)
                                ).foregroundColor(Color.textDark())
                            }

                            Divider()

                            MetricRow(
                                icon: "figure.run", title: "Distance",
                                value: String(format: "%.2f KM", session.totalDistance))
                            MetricRow(
                                icon: "clock", title: "Duration",
                                value: f.formatDuration(session.totalDuration))
                            MetricRow(
                                icon: "speedometer", title: "Avg Speed",
                                value: String(format: "%.1f KM/H", session.averageSpeed))

                            //TBA
                            // MetricRow(icon: "heart", title: "Avg Heart Rate", value: "\(session.averageHeartRate) BPM")

                            MetricRow(
                                icon: "flame", title: "Calories",
                                value: String(format: "%.0f kcal", session.totalCalories))
                        }.padding()
    


                    }                    .background(Color.secondaryLight())
                        .cornerRadius(10)

                    VStack(spacing: 10) {
                        // New Routes Section
                        Text("Routes")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(Color.textLight())
                            .frame(alignment: .center)
                        MapView(routeCoordinates: session.routeCoordinates.map { $0.coordinate })
                            .frame(height: 150).cornerRadius(10)
                    }
                    // Segments List
                    if !session.segments.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center) {
                                Text("Session Segments").font(.custom("Jersey15-Regular", size: 20))
                                    .foregroundColor(Color.textLight())

                                Spacer()
                                Text("\(session.segments.count) segments")
                                    .foregroundColor(Color.textLight())
                            }

                            ForEach(session.segments, id: \.startTime) { segment in
                                SegmentDetailCard(segment: segment)
                            }
                        }.frame(width: UIScreen.main.bounds.width * 0.8)

                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
    }
    struct SegmentDetailCard: View {
        let segment: SessionSegment
        let f = DateAndDurationFormatter()  // Instance of the formatter

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Segment Start")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(.textDark())
                        Text(segment.startTime, style: .time)
                            .font(.custom("Jersey15-Regular", size: 20))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Distance")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(.backgroundLight())
                        Text(String(format: "%.2f km", segment.distance))
                            .font(.custom("Jersey15-Regular", size: 20))
                    }
                }

                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Duration")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(Color.backgroundLight())
                        Text(f.formatDuration(segment.duration))
                            .font(.custom("Jersey15-Regular", size: 20))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Avg Speed")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(Color.backgroundLight())
                        Text(String(format: "%.1f km/h", segment.averageSpeed))
                            .font(.custom("Jersey15-Regular", size: 20))
                    }
                }

                HStack {
                    VStack(alignment: .trailing) {
                        Text("Calories")
                            .font(.custom("Jersey15-Regular", size: 20))
                            .foregroundColor(Color.backgroundLight())
                        Text(String(format: "%.0f kcal", segment.calories))
                            .font(.custom("Jersey15-Regular", size: 20))
                    }
                    Spacer()

                }
            }
            .padding()
            .background(Color.secondaryLight())
            .cornerRadius(10)
        }

    }
}
