import SwiftUI

struct AllSessionsView: View {
    @State private var sessions: [SessionSummary] = []  // List of session summaries
    @State private var isLoading: Bool = false  // [NEW] State for indicating loading status
    @State private var errorMessage: String? = nil  // [NEW] State for errors
    private let storage = SessionStorage()  // Storage for session data
    private let formatter = DateAndDurationFormatter()  // [UPDATED] Shared formatter instance

    var body: some View {
        ZStack {
            Color.backgroundLight()  // Apply background color
                .edgesIgnoringSafeArea(.all)  // Ensure it covers the entire view

            VStack {  // [UPDATED] Use VStack to arrange "PORCU" and content
                HStack {
                    Text("All sessions")
                        .font(.custom("Jersey15-Regular", size: 25))
                        .foregroundColor(Color.textLight())
                        .frame(alignment: .center)
                        .background(Color.backgroundLight())
                }
                Group {
                    if isLoading {
                        ProgressView("Refreshing Rides History...")
                    } else if sessions.isEmpty {
                        Text("No history available.")
                            .foregroundColor(Color.textLight())
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {  // Simple vertical stack with standard spacing
                                ForEach(sessions.indices, id: \.self) { index in
                                    let session = sessions[index]
                                    let randomColor = Color.randomPaletteColor(for: index)

                                    NavigationLink(
                                        destination: SessionDetailView(session: session)
                                    ) {
                                        SessionListCard(
                                            session: session, formatter: formatter,
                                            backgroundColor: randomColor
                                        )
                                        .frame(width: UIScreen.main.bounds.width * 0.8)  // Card width
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)  // Horizontal padding for the entire stack
                        }
                    }
                }.background(Color.backgroundLight())
            }
            .onAppear {
                if sessions.isEmpty {
                    refreshSessions()
                }
            }
        }
    }

    private func refreshSessions() {
        guard !isLoading else { return }  // [NEW] Prevent duplicate refreshes
        isLoading = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async {  // [UPDATED] Perform data fetching in a background thread
            storage.fetchAndStoreWorkouts { success, error in
                DispatchQueue.main.async {  // [UPDATED] Update UI on main thread
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription  // [NEW] Capture error
                        return
                    }
                    if success {
                        sessions = storage.getAllSessions().sorted(by: { $0.date > $1.date })  // [UPDATED] Reload sorted sessions
                    }
                }
            }
        }
    }
}

#Preview {
    AllSessionsView()
}
