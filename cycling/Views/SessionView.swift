import CoreLocation
import SwiftUI

struct SessionView: View {
    @StateObject private var viewModel = SessionViewModel()
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []  // Coordinates for route tracking
    @State private var isSessionActive = false
    @Environment(\.presentationMode) var presentationMode  // For dismissing the view
    private let f = DateAndDurationFormatter()  // Instance of the formatter
    init() {
        print("SessionView initialized")
    }
    var body: some View {
        ZStack {
            Color.backgroundLight()  // Apply background color
                .edgesIgnoringSafeArea(.all)  // Ensure it covers the entire view

            VStack {
                HStack {
                    Text("PORCU")
                        .font(.custom("Jersey15-Regular", size: 25))
                        .foregroundColor(Color.textLight())
                        .frame(alignment: .center)
                        .background(Color.backgroundLight())

                }
                .background(Color.secondaryLight())
                .frame(maxWidth: .infinity)
                // Metrics
                VStack(spacing: 20) {
                    CardView(
                        backgroundColor: Color.textLight(),
                        cardName: "Duration",
                        metric: f.formatDuration(viewModel.metrics.workoutTime),
                        unit: ""
                    )

                    CardView(
                        backgroundColor: Color.textLight(),
                        cardName: "Distance",
                        metric: String(format: "%.2f", viewModel.metrics.distance),
                        unit: "KM"
                    )

                    CardView(
                        backgroundColor: Color.textLight(),
                        cardName: "Speed",
                        metric: String(format: "%.1f", viewModel.metrics.currentSpeed),
                        unit: "KM/H"
                    )
                    // Session History (if applicable)
                    if !viewModel.sessionSegments.isEmpty {
                        VStack(alignment: .center, spacing: 10) {
                            Text("Segments")
                                .font(.custom("Jersey15-Regular", size: 20))
                                .foregroundColor(Color.textLight())
                                .frame(alignment: .center)

                            ScrollView {
                                LazyVStack {
                                    ForEach(viewModel.sessionSegments, id: \.startTime) { segment in
                                        SessionSegmentView(segment: segment)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, UIScreen.main.bounds.height * 0.05)

                Spacer()

                // Control Buttons
                HStack(spacing: 36) {
                    switch viewModel.sessionState {
                    case .notStarted:
                        ActionButton(
                            title: "Start a ride!",
                            backgroundColor: Color(hex: "#F95A2C"),
                            width: 326
                        ) {
                            viewModel.startSession()
                            locationManager.startTracking()
                            routeCoordinates.removeAll()
                        }

                    case .active:
                        ActionButton(
                            title: "Pause",
                            backgroundColor: Color(hex: "#FFBD12"),
                            width: 145
                        ) {
                            viewModel.pauseSession()
                            locationManager.stopTracking()
                        }

                        ActionButton(
                            title: "End",
                            backgroundColor: Color(hex: "#9FA4B4"),
                            width: 145
                        ) {
                            viewModel.endSession()
                            locationManager.stopTracking()
                        }

                    case .paused:
                        ActionButton(
                            title: "Resume",
                            backgroundColor: Color(hex: "#00C6AE"),
                            width: 145
                        ) {
                            viewModel.resumeSession()
                            locationManager.startTracking()
                        }

                        ActionButton(
                            title: "End",
                            backgroundColor: Color(hex: "#9FA4B4"),
                            width: 145
                        ) {
                            viewModel.endSession()
                            locationManager.stopTracking()
                        }

                    case .finished:
                        ActionButton(
                            title: "Start a ride!",
                            backgroundColor: Color(hex: "#F95A2C"),
                            width: 326
                        ) {
                            viewModel.startSession()
                            locationManager.resetTracking()
                            routeCoordinates.removeAll()
                        }
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .frame(width: UIScreen.main.bounds.width * 0.8)
            }
            .onReceive(locationManager.$location) { location in
                guard let location = location else { return }
                routeCoordinates.append(location.coordinate)

                // Limit the size of the routeCoordinates array
                if routeCoordinates.count > 1000 {
                    routeCoordinates.removeFirst(routeCoordinates.count - 1000)
                }

                viewModel.updateRouteCoordinates(routeCoordinates)  // Save coordinates in ViewModel
            }
        }
    }
}

#Preview {
    SessionView()
}
