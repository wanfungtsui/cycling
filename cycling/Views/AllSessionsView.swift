import SwiftUI

struct AllSessionsView: View {
    @State private var sessions: [SessionSummary] = [] // List of session summaries
    @State private var isLoading: Bool = false         // [NEW] State for indicating loading status
    @State private var errorMessage: String? = nil     // [NEW] State for errors
    private let storage = SessionStorage()             // Storage for session data
    private let formatter = DateAndDurationFormatter() // [UPDATED] Shared formatter instance

    var body: some View {
        NavigationView {
            Group { // [UPDATED] Group for conditional UI display
                if isLoading { 
                    ProgressView("Loading sessions...") // [NEW] Loading indicator
                } else if sessions.isEmpty { 
                    Text("No sessions available.") // [NEW] Empty state message
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) { // [UPDATED] Use LazyVStack for efficient rendering
                            ForEach(sessions) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionListCard(session: session, formatter: formatter) // [UPDATED] Pass shared formatter
                                }
                                .buttonStyle(PlainButtonStyle()) // [NEW] Remove default button styling
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("All Sessions")
            .toolbar { // [NEW] Toolbar for manual refresh
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshSessions) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading) // [NEW] Disable refresh button while loading
                }
            }
            .onAppear {
                if sessions.isEmpty { // [NEW] Fetch sessions only if list is empty
                    refreshSessions()
                }
            }

        }
    }

    private func refreshSessions() {
        guard !isLoading else { return } // [NEW] Prevent duplicate refreshes
        isLoading = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async { // [UPDATED] Perform data fetching in a background thread
            storage.fetchAndStoreWorkouts { success, error in
                DispatchQueue.main.async { // [UPDATED] Update UI on main thread
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription // [NEW] Capture error
                        return
                    }
                    if success {
                        sessions = storage.getAllSessions().sorted(by: { $0.date > $1.date }) // [UPDATED] Reload sorted sessions
                    }
                }
            }
        }
    }
}

// Updated SessionListCard with shared formatter
struct SessionListCard: View {
    let session: SessionSummary
    let formatter: DateAndDurationFormatter // [UPDATED] Pass shared formatter to avoid recreating instances

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatter.formattedDate(session.date))
            }
            HStack {
                Text("Total Distance")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.2f km", session.totalDistance))
            }

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")

                        .foregroundColor(.secondary)
                    Text(formatter.formatDuration(session.totalDuration)) // [UNCHANGED]
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Avg Speed")

                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km/h", session.averageSpeed))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Calories")

                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f kcal", session.totalCalories))
                }
            }
            Text("\(session.segments.count) segments")

                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
