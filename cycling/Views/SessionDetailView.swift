import SwiftUI
import MapKit

struct SessionDetailView: View {
    let session: SessionSummary
    let f = DateAndDurationFormatter() // Instance of the formatter

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Map View for Route
                MapView(routeCoordinates: session.routeCoordinates.map { $0.coordinate })
                    .frame(height: UIScreen.main.bounds.height / 4)
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Session Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(session.date, style: .date)
                        Spacer()
                        Text(session.date, style: .time)
                    }
                    
                    Divider()
                    
                    MetricRow(icon: "figure.run", title: "Distance", value: String(format: "%.2f km", session.totalDistance))
                    MetricRow(icon: "clock", title: "Duration", value: f.formatDuration(session.totalDuration))
                    MetricRow(icon: "speedometer", title: "Avg Speed", value: String(format: "%.1f km/h", session.averageSpeed))
                    
                    //TBA
                    // MetricRow(icon: "heart", title: "Avg Heart Rate", value: "\(session.averageHeartRate) BPM")
                   
                    MetricRow(icon: "flame", title: "Calories", value: String(format: "%.0f kcal", session.totalCalories))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Segments List
                if !session.segments.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Session Segments")
                            Spacer()
                            Text("\(session.segments.count) segments")

                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ForEach(session.segments, id: \.startTime) { segment in
                            SegmentDetailCard(segment: segment)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
    }



struct SegmentDetailCard: View {
    let segment: SessionSegment
    let f = DateAndDurationFormatter() // Instance of the formatter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Segment Start")
       
                        .foregroundColor(.secondary)
                    Text(segment.startTime, style: .time)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Distance")
                
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f km", segment.distance))
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .foregroundColor(.secondary)
                    Text(f.formatDuration(segment.duration))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg Speed")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km/h", segment.averageSpeed))
                }
            }
            
            HStack {
                /*
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .foregroundColor(.secondary)
                    Text("\(segment.averageHeartRate) BPM")
                }
                Spacer()
                */
                VStack(alignment: .trailing) {
                    Text("Calories")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f kcal", segment.calories))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

} 
}
}