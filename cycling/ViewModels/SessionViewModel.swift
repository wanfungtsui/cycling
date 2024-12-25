import Foundation
import Combine

// Add this line at the top if needed
// import cycling  // Only if the model is in a different module

class SessionViewModel: ObservableObject {
    @Published var metrics = CyclingMetrics()
    @Published var sessionState: SessionState = .notStarted
    @Published var sessionSegments: [SessionSegment] = []
    
    private var timer: Timer?
    private var segmentStartTime: Date?
    private let storage = SessionStorage()
    
    func startSession() {
        sessionState = .active
        segmentStartTime = Date()
        startTimer()
    }
    
    func pauseSession() {
        sessionState = .paused
        timer?.invalidate()
        saveSegment()
    }
    
    func resumeSession() {
        sessionState = .active
        segmentStartTime = Date()
        startTimer()
    }
    
    func endSession() {
        if sessionState == .active {
            saveSegment()
        }
        
        // Calculate and save session summary
        let summary = calculateSessionSummary()
        storage.saveSummary(summary)
        
        sessionState = .finished
        timer?.invalidate()
        sessionSegments.removeAll()
        metrics = CyclingMetrics()
    }
    
    private func saveSegment() {
        guard let startTime = segmentStartTime else { return }
        
        let segment = SessionSegment(
            startTime: startTime,
            duration: metrics.workoutTime,
            distance: metrics.distance,
            averageSpeed: metrics.currentSpeed,
            averageHeartRate: metrics.heartRate,
            calories: metrics.calories
        )
        
        sessionSegments.insert(segment, at: 0) // Insert at beginning for reverse chronological order
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    private func updateMetrics() {
        // Update workout time
        metrics.workoutTime += 1
        
        // In a real app, these would come from actual sensors
        // For now, we'll simulate some random changes
        metrics.currentSpeed = Double.random(in: 15...30)
        metrics.heartRate = Int.random(in: 120...150)
        metrics.distance += metrics.currentSpeed / 3600 // Convert km/h to km/s
        metrics.calories = metrics.workoutTime * 0.2 // Simple calculation for demo
    }
    
    private func calculateSessionSummary() -> SessionSummary {
        let totalDuration = sessionSegments.reduce(0) { $0 + $1.duration }
        let totalDistance = sessionSegments.reduce(0) { $0 + $1.distance }
        
        // Calculate weighted average speed based on segment durations
        let weightedSpeed = sessionSegments.reduce(0) { $0 + ($1.averageSpeed * $1.duration) }
        let averageSpeed = totalDuration > 0 ? weightedSpeed / totalDuration : 0
        
        // Calculate weighted average heart rate based on segment durations
        let weightedHeartRate = sessionSegments.reduce(0) { $0 + (Double($1.averageHeartRate) * $1.duration) }
        let averageHeartRate = totalDuration > 0 ? Int(weightedHeartRate / totalDuration) : 0
        
        let totalCalories = sessionSegments.reduce(0) { $0 + $1.calories }
        
        return SessionSummary(
            id: UUID(),
            date: Date(),
            totalDistance: totalDistance,
            totalDuration: totalDuration,
            averageSpeed: averageSpeed,
            averageHeartRate: averageHeartRate,
            totalCalories: totalCalories,
            segments: sessionSegments
        )
    }
} 