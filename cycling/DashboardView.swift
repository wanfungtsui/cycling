import SwiftUI
import Charts

// ViewModel to manage and provide session data
class DashboardViewModel: ObservableObject {
    @Published var sessions: [SessionSummary] = [] // Holds all session summaries
    private let storage = SessionStorage() // Storage service for sessions
    
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
    @StateObject private var viewModel = DashboardViewModel() // ViewModel instance
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.sessions.isEmpty {
                        // Section for today's summary
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Summary")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Card displaying today's session metrics
                            TodaySummaryCard(sessions: viewModel.todaysSessions)
                                .padding(.horizontal)
                        }
                        
                        // Section for charts
                        HStack(spacing: 20) {
                            // Speed chart
                            ChartView(
                                title: "Speed (km/h)",
                                data: viewModel.sessions.prefix(5).reversed().enumerated().map { (index, session) in
                                    (index + 1, session.averageSpeed)
                                },
                                color: .blue
                            )
                            
                            // Heart rate chart
                            ChartView(
                                title: "Heart Rate (BPM)",
                                data: viewModel.sessions.prefix(5).reversed().enumerated().map { (index, session) in
                                    (index + 1, Double(session.averageHeartRate))
                                },
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Section for recent sessions
                        HStack {
                            Text("Recent Sessions")
                                .font(.headline)
                            Spacer()
                            NavigationLink(destination: AllSessionsView()) {
                                Text("All")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        // List of recent session summaries
                        ForEach(viewModel.sessions.prefix(5)) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionSummaryView(session: session)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle()) // Ensures the link looks like a card
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadSessions() // Load sessions when view appears
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
    private var averageHeartRate: Int {
        sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageHeartRate } / sessions.count
    }
    
    // Calculate total calories
    private var totalCalories: Double {
        sessions.reduce(0) { $0 + $1.totalCalories }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            MetricRow(icon: "figure.run", title: "Distance", value: String(format: "%.1f km", totalDistance))
            Divider()
            MetricRow(icon: "clock", title: "Time", value: formatDuration(totalDuration))
            Divider()
            MetricRow(icon: "speedometer", title: "Avg Speed", value: String(format: "%.1f km/h", averageSpeed))
            Divider()
            MetricRow(icon: "heart", title: "Avg Heart Rate", value: "\(averageHeartRate) BPM")
            Divider()
            MetricRow(icon: "flame", title: "Calories", value: String(format: "%.0f kcal", totalCalories))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // Format duration into hours and minutes
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

// Row component for displaying a metric with an icon
struct MetricRow: View {
    let icon: String // Icon name
    let title: String // Metric title
    let value: String // Metric value
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

// View for displaying a summary of a session
struct SessionSummaryView: View {
    let session: SessionSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.date, style: .date)
                .font(.headline)
            
            HStack {
                Text(String(format: "%.1f km", session.totalDistance))
                Spacer()
                Text(String(format: "%.1f km/h", session.averageSpeed))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
} 
