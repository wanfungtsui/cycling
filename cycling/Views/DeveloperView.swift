import HealthKit
import SwiftUI

struct DeveloperView: View {
    @State private var sessions: [SessionSummary] = []
    @State private var isLoading = false
    private let storage = SessionStorage()
    private let f = DateAndDurationFormatter() // Instance of the formatter
    init() {
        print("DeveloperView initialized")
    }
    var body: some View {
        VStack {
            Button(action: fetchAndSyncHealthKitData) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Fetch and Show Sessions")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()

            List(sessions) { session in
                VStack(alignment: .leading) {
                    Text("Date: \(f.formattedDate(session.date))")
                    Text("Total Distance: \(String(format: "%.2f km", session.totalDistance))")
                    Text("Total Duration: \(f.formatDuration(session.totalDuration))")
                    Text("Average Speed: \(String(format: "%.2f km/h", session.averageSpeed))")
                }
                .padding()
            }
        }
        .navigationTitle("Developer")
    }

    private func fetchAndSyncHealthKitData() {
        isLoading = true
        sessions.removeAll()

        // Fetch and store HealthKit cycling data
        storage.fetchAndStoreWorkouts { success, error in
            if let error = error {
                print("Error fetching and storing workouts: \(error.localizedDescription)")
                isLoading = false
                return
            }

            if success {
                // Clear existing sessions to avoid duplicates
                // Removed unnecessary print statement
            }
            isLoading = false
        }
    }

    private func logAllSessions() {
        let sessions = storage.getAllSessions()
        print("=== All Stored Sessions ===")
        for session in sessions {
            print(session)
        }
        print("===========================")
    }

}

#Preview {
    DeveloperView()
}
