import SwiftUI

struct SessionView: View {
    @StateObject private var viewModel = SessionViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Metrics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    MetricView(title: "Time", value: formatTime(viewModel.metrics.workoutTime))
                    MetricView(title: "Distance", value: String(format: "%.2f km", viewModel.metrics.distance))
                    MetricView(title: "Speed", value: String(format: "%.1f km/h", viewModel.metrics.currentSpeed))
                    MetricView(title: "Heart Rate", value: "\(viewModel.metrics.heartRate) BPM")
                    MetricView(title: "Calories", value: String(format: "%.0f kcal", viewModel.metrics.calories))
                }
                .padding()
                
                // Session History (always shown when segments exist)
                if !viewModel.sessionSegments.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Session Segments")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.sessionSegments, id: \.startTime) { segment in
                                    SessionSegmentView(segment: segment)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 30) {
                    switch viewModel.sessionState {
                    case .notStarted:
                        Button(action: { viewModel.startSession() }) {
                            Text("Start")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        
                    case .active:
                        Button(action: { viewModel.pauseSession() }) {
                            Text("Pause")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }
                        
                        Button(action: { viewModel.endSession() }) {
                            Text("End")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                        
                    case .paused:
                        Button(action: { viewModel.resumeSession() }) {
                            Text("Resume")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        
                        Button(action: { viewModel.endSession() }) {
                            Text("End")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                        
                    case .finished:
                        Button(action: { viewModel.startSession() }) {
                            Text("New Session")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 160, height: 50)
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Cycling Session")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct SessionSegmentView: View {
    let segment: SessionSegment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(segment.startTime, style: .time)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f km", segment.distance))
                    .font(.headline)
            }
            
            HStack {
                Text("Duration: \(formatDuration(segment.duration))")
                Spacer()
                Text("Avg Speed: \(String(format: "%.1f km/h", segment.averageSpeed))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    SessionView()
} 