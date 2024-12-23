import SwiftUI
import Charts

class DashboardViewModel: ObservableObject {
    @Published var sessions: [SessionSummary] = []
    private let storage = SessionStorage()
    
    func loadSessions() {
        sessions = storage.getAllSessions().sorted(by: { $0.date > $1.date })
    }
    
    var todaysSessions: [SessionSummary] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.startOfDay(for: $0.date) == today }
    }
}

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.sessions.isEmpty {
                        // Today's Summary Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Summary")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TodaySummaryCard(sessions: viewModel.todaysSessions)
                                .padding(.horizontal)
                        }
                        
                        // Speed Chart Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Speed Trend")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            SpeedChartView(sessions: viewModel.sessions)
                                .frame(height: 250)
                                .padding(.horizontal)
                        }
                        
                        // Recent Sessions Section
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
                        
                        ForEach(viewModel.sessions.prefix(5)) { session in
                            SessionSummaryView(session: session)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadSessions()
            }
        }
    }
}

struct TodaySummaryCard: View {
    let sessions: [SessionSummary]
    
    private var totalDistance: Double {
        sessions.reduce(0) { $0 + $1.totalDistance }
    }
    
    private var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.totalDuration }
    }
    
    private var averageSpeed: Double {
        sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageSpeed } / Double(sessions.count)
    }
    
    private var averageHeartRate: Int {
        sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageHeartRate } / sessions.count
    }
    
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
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct MetricRow: View {
    let icon: String
    let title: String
    let value: String
    
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

struct SpeedChartView: View {
    let sessions: [SessionSummary]
    
    private var chartData: [(index: Int, date: Date, speed: Double)] {
        Array(sessions.prefix(7))
            .reversed()
            .enumerated()
            .map { (index, session) in
                (index, session.date, session.averageSpeed)
            }
    }
    
    var body: some View {
        Chart {
            ForEach(chartData, id: \.index) { item in
                BarMark(
                    x: .value("Session", item.index),
                    y: .value("Speed", item.speed)
                )
                .foregroundStyle(.blue.opacity(0.3))
                
                PointMark(
                    x: .value("Session", item.index),
                    y: .value("Speed", item.speed)
                )
                .foregroundStyle(.blue)
                .symbolSize(100)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let speed = value.as(Double.self) {
                        Text("\(Int(speed)) km/h")
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let index = value.as(Int.self),
                       index < chartData.count {
                        let date = chartData[index].date
                        Text(date.formatted(.dateTime.month().day().hour().minute()))
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AllSessionsView: View {
    var body: some View {
        Text("All Sessions")
            .navigationTitle("All Sessions")
    }
}

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