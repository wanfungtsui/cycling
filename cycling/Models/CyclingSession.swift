import Foundation

struct CyclingMetrics {
    var workoutTime: TimeInterval = 0
    var distance: Double = 0      // in kilometers
    var currentSpeed: Double = 0  // in km/h
    var heartRate: Int = 0        // in BPM
    var calories: Double = 0      // in kcal
}

struct SessionSegment: Codable {
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
    let segments: [SessionSegment]
    
    init(id: UUID = UUID(), 
         date: Date, 
         totalDistance: Double, 
         totalDuration: TimeInterval, 
         averageSpeed: Double, 
         averageHeartRate: Int, 
         totalCalories: Double, 
         segments: [SessionSegment]) {
        self.id = id
        self.date = date
        self.totalDistance = totalDistance
        self.totalDuration = totalDuration
        self.averageSpeed = averageSpeed
        self.averageHeartRate = averageHeartRate
        self.totalCalories = totalCalories
        self.segments = segments
    }
} 
