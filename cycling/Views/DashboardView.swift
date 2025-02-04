import Charts
import SwiftUI

// ViewModel to manage and provide session data
class DashboardViewModel: ObservableObject {
    @Published var sessions: [SessionSummary] = []  // Holds all session summaries
    private let storage = SessionStorage()  // Storage service for sessions

    // Loads sessions from storage and sorts them by date
    func loadSessions() {
        sessions = storage.getAllSessions().sorted(by: { $0.date > $1.date })
    }

    // Filters sessions to only include today's sessions
    var todaysSessions: [SessionSummary] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.startOfDay(for: $0.date) == today }
    }
}

// Main view for the dashboard
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()  // ViewModel instance
    private let f = DateAndDurationFormatter()  // Instance of the formatter

    init() {
        print("Dashboard initialized")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight()  // Set the background color for the entire view
                    .edgesIgnoringSafeArea(.all)  // Ensure the color covers the entire screen

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("PORCU")
                                .font(.custom("Jersey15-Regular", size: 25))
                                .foregroundColor(Color.textLight())
                                .frame(alignment: .center)
                                .background(Color.backgroundLight())

                        }
                            // Section for today's summary
                            VStack(spacing: 20) {
                                Text("Today's Summary")
                                    .font(.custom("Jersey15-Regular", size: 20))
                                    .frame(alignment: .center)
                                    .foregroundColor(Color.textLight())

                                // Card displaying today's session metrics
                                TodaySummaryCard(sessions: viewModel.todaysSessions)
                                    .padding(.horizontal)
                                    .frame(width: UIScreen.main.bounds.width * 0.8)

                            }

                            VStack(spacing: 10) {

                                NavigationLink(destination: SessionView()) {
                                    VStack {
                                        Text("Start a Ride!")
                                            .bold()
                                        
                                            .foregroundColor(Color.backgroundLight())
                                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 58)
                                            .font(.custom("Jersey15-Regular", size: 20))
                                            .background(Color.primaryDark())
                                        
                                    }               .cornerRadius(10)

                                }

                            }
                            // Section for charts
                            VStack(spacing: 10) {
                                Text("Leaderboard")
                                    .font(.custom("Jersey15-Regular", size: 20))
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                                    .foregroundColor(Color.textLight())

                                // Speed chart
                                ChartView(
                                    title: "Speed",
                                    data: viewModel.sessions.prefix(5).reversed().enumerated().map {
                                        (index, session) in
                                        (index + 1, session.averageSpeed)
                                    }
                                ).frame(width: UIScreen.main.bounds.width * 0.8)
                            }
                            //.padding(.horizontal)

                            // Section for recent sessions
                            HStack(spacing: 30) {
                                Text("Recent Sessions")
                                    .font(.custom("Jersey15-Regular", size: 20))
                                    .foregroundColor(Color.textLight())
                                Spacer()
                                NavigationLink(destination: AllSessionsView()) {

                                    Text("More")
                                        .foregroundColor(Color.secondaryDark())
                                        .font(.custom("Jersey15-Regular", size: 15))

                                }
                            }
                            //.frame(width: 326)

                            // List of recent session summaries
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment:.firstTextBaseline  ,   spacing: 15) {
                                    ForEach(viewModel.sessions.prefix(3)) { session in
                                        NavigationLink(
                                            destination: SessionDetailView(session: session)
                                        ) {
                                            SessionSummaryView(session: session)
                                        }
                                        .buttonStyle(PlainButtonStyle())  // Ensures the link looks like a card
                                    }
                                }
                            }
                        
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.8)
                .onAppear {
                    viewModel.loadSessions()  // Load sessions when view appears
                }
            }
        }
    }
}

// Card displaying summary metrics for today's sessions
struct TodaySummaryCard: View {
    let sessions: [SessionSummary]

    // Calculate total distance
    private var totalDistance: Double {
        sessions.reduce(0) { $0 + $1.totalDistance }
    }

    // Calculate total duration
    private var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.totalDuration }
    }

    // Calculate average speed
    private var averageSpeed: Double {
        sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageSpeed } / Double(sessions.count)
    }

    // Calculate average heart rate
    /*
    private var averageHeartRate: Int {
        sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageHeartRate } / sessions.count
    }
    */

    // Calculate total calories
    private var totalCalories: Double {
        sessions.reduce(0) { $0 + $1.totalCalories }
    }
    private let f = DateAndDurationFormatter()  // Instance of the formatter

    var body: some View {
  
            VStack(alignment: .leading, spacing: 5) {
                MetricRow(
                    icon: "figure.run", title: "Total distance",
                    value: String(format: "%.1f km", totalDistance))
          
                MetricRow(icon: "clock", title: "Total duration", value: f.formatDuration(totalDuration))
  
                MetricRow(
                    icon: "speedometer", title: "Avg. speed",
                    value: String(format: "%.1f KM/H", averageSpeed))
                // MetricRow(icon: "heart", title: "Avg Heart Rate", value: "\(averageHeartRate) BPM")
                // Divider()
                MetricRow(
                    icon: "flame", title: "Calories", value: String(format: "%.0f kcal", totalCalories))
            }
               .padding()// Apply offset to the ZStack

               .background(Color.secondaryLight())
               .cornerRadius(10)
        .frame(width: UIScreen.main.bounds.width * 0.8)
    }

}

// View for displaying a summary of a session
struct SessionSummaryView: View {
    let session: SessionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Add MapView at the top
            MapView(routeCoordinates: session.routeCoordinates.map { $0.coordinate })
                .disabled(true)  // Disable user interaction

            Text(session.date, style: .date)
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textLight())

            HStack {
                Text(String(format: "%.2f km", session.totalDistance)).font(
                    .custom("Jersey15-Regular", size: 15)
                )
                .foregroundColor(Color.textLight())
                Spacer()
                Text(String(format: "%.2f km/h", session.averageSpeed)).font(
                    .custom("Jersey15-Regular", size: 15)
                )
                .foregroundColor(Color.textLight())
            }
            .foregroundColor(.secondary)
        }
        .padding(.bottom,5)
                       .cornerRadius(10)

        .frame(width: UIScreen.main.bounds.width * 0.5, height: 154)
    }
}

#Preview {
    DashboardView()
}
