import Foundation

struct CyclingMetrics {
    var workoutTime: TimeInterval = 0
    var distance: Double = 0      // in kilometers
    var currentSpeed: Double = 0  // in km/h
    var heartRate: Int = 0        // in BPM
    var calories: Double = 0      // in kcal
}

struct SessionSegment {
    let startTime: Date
    let duration: TimeInterval
    let distance: Double
    let averageSpeed: Double
    let averageHeartRate: Int
    let calories: Double
}

enum SessionState {
    case notStarted
    case active
    case paused
    case finished
}

struct SessionSummary: Codable, Identifiable {
    let id: UUID
    let date: Date
    let totalDistance: Double
    let totalDuration: TimeInterval
    let averageSpeed: Double
    let averageHeartRate: Int
    let totalCalories: Double
} 
