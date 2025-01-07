import SwiftUI
import MapKit

struct SessionDetailView: View {
    let session: SessionSummary
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Map View for Route
                MapView(routeCoordinates: session.routeCoordinates.map { $0.coordinate }) // Convert CodableCoordinate to CLLocationCoordinate2D
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Session Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(session.date, style: .date)
                            .font(.headline)
                        Spacer()
                        Text(session.date, style: .time)
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    MetricRow(icon: "figure.run", title: "Distance", value: String(format: "%.2f km", session.totalDistance))
                    MetricRow(icon: "clock", title: "Duration", value: formatDuration(session.totalDuration))
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
                                .font(.headline)
                            Spacer()
                            Text("\(session.segments.count) segments")
                                .font(.subheadline)
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
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct MapView: UIViewRepresentable {
    var routeCoordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}



struct SegmentDetailCard: View {
    let segment: SessionSegment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Segment Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(segment.startTime, style: .time)
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f km", segment.distance))
                        .font(.headline)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(segment.duration))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg Speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km/h", segment.averageSpeed))
                }
            }
            
            HStack {
                /*
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(segment.averageHeartRate) BPM")
                }
                Spacer()
                */
                VStack(alignment: .trailing) {
                    Text("Calories")
                        .font(.caption)
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
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 
