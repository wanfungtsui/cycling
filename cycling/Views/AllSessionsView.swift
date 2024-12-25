import SwiftUI

class AllSessionsViewModel: ObservableObject {
    @Published var sessions: [SessionSummary] = []
    private let storage = SessionStorage()
    
    func loadSessions() {
        sessions = storage.getAllSessions().sorted(by: { $0.date > $1.date })
    }
    
    var groupedSessions: [String: [SessionSummary]] {
        Dictionary(grouping: sessions) { session in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: session.date)
        }
    }
}

struct AllSessionsView: View {
    @StateObject private var viewModel = AllSessionsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.groupedSessions.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(date).font(.headline).padding(.horizontal).frame(maxWidth: .infinity, alignment: .leading)) {
                        ForEach(viewModel.groupedSessions[date] ?? []) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionListCard(session: session)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Sessions")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadSessions()
        }
    }
}

struct SessionListCard: View {
    let session: SessionSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Total Distance
            HStack {
                Text("Total Distance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f km", session.totalDistance))
                    .font(.headline)
            }
            
            Divider()
            
            // Stats
            HStack {
                // Duration
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(session.totalDuration))
                }
                
                Spacer()
                
                // Speed
                VStack(alignment: .center) {
                    Text("Avg Speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km/h", session.averageSpeed))
                }
                
                Spacer()
                
                // Calories
                VStack(alignment: .trailing) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f kcal", session.totalCalories))
                }
            }
            
            Text("\(session.segments.count) segments")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NavigationView {
        AllSessionsView()
    }
} 