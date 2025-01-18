import Foundation
import Combine
import HealthKit
import CoreMotion
import UIKit
import CoreLocation

// ViewModel to manage cycling session data and interactions
class SessionViewModel: ObservableObject {
    @Published var metrics = CyclingMetrics() // Holds current session metrics
    @Published var sessionState: SessionState = .notStarted // Tracks the state of the session
    @Published var sessionSegments: [SessionSegment] = [] // Stores segments of the session
    
    private var timer: Timer? // Timer to update metrics periodically
    private var segmentStartTime: Date? // Start time of the current segment
    private let storage = SessionStorage() // Storage for session summaries
    private var healthKitManager = HealthKitManager.shared // Singleton for HealthKit interactions
    private let pedometer = CMPedometer() // Core Motion pedometer for distance and speed
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid // Background task identifier
    private var locationManager = LocationManager.shared // Shared LocationManager
    private var cancellables = Set<AnyCancellable>() // Combine cancellables for observing LocationManager
    private var routeCoordinates: [CLLocationCoordinate2D] = [] // Add this line
    private var accumulatedDistance: Double = 0.0 // To store the distance before pausing

    
    init() {
        bindLocationManager()
        //requestPermissions()
    }
/*
    private func requestPermissions() {
           locationManager.requestPermission() // Request location permissions
           //requestHealthKitAuthorization()
       }
       */
 
 /*
    private func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted.")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
*/
    // Bind LocationManager updates to metrics
    private func bindLocationManager() {
        locationManager.$speed
            .receive(on: DispatchQueue.main)
            .assign(to: \.metrics.currentSpeed, on: self)
            .store(in: &cancellables)

        locationManager.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                guard let self = self else { return }
                self.metrics.distance = self.accumulatedDistance + distance
            }
            .store(in: &cancellables)
    }
   
    func startSession() {
        sessionState = .active
        segmentStartTime = Date()
        accumulatedDistance = sessionSegments.reduce(0) { $0 + $1.distance } // Sum up distances from previous segments
        metrics.distance = accumulatedDistance // Initialize metrics distance with accumulated distance
        startTimer()
        startPedometer()
        registerBackgroundTask() // Register background task to continue updates
    }

    func pauseSession() {
        sessionState = .paused
        timer?.invalidate()
        stopPedometer()
        saveSegment()
        accumulatedDistance = metrics.distance
        metrics.currentSpeed = 0.0
        endBackgroundTask()
    }

    func resumeSession() {
        sessionState = .active
        segmentStartTime = Date()
        startTimer()
        startPedometer()
        registerBackgroundTask()
    }
    
    // Ends the current session
    func endSession() {
        if sessionState == .active {
            saveSegment() // Save the last segment if session is active
        }
        
        // Calculate and save session summary
        let summary = calculateSessionSummary()
        storage.saveSummary(summary)
        
        sessionState = .finished
        timer?.invalidate()
        sessionSegments.removeAll()
        metrics = CyclingMetrics()
        accumulatedDistance = 0.0
        // Complete the session and save data to HealthKit
        completeSession()
        endBackgroundTask() // End background task
    }
    
    // Saves the current segment of the session
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
    
    // Starts the timer to update metrics every second
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    // Updates the session metrics
    private func updateMetrics() {
        // Increment workout time
        metrics.workoutTime += 1
        
        // Mock heart rate data
        //metrics.heartRate = Int.random(in: 120...150)
        // Real data updates will be handled by pedometer
    }
    
    // Starts the pedometer to track distance and speed
    private func startPedometer() {
        guard CMPedometer.isDistanceAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                // Convert distance from meters to kilometers and add accumulated distance
                let newDistance = (data.distance?.doubleValue ?? 0.0) / 1000.0
                self.metrics.distance = self.accumulatedDistance + newDistance
                
                // Convert speed from meters per second to kilometers per hour
                if let pace = data.currentPace?.doubleValue {
                    self.metrics.currentSpeed = 3.6 / pace // pace is in seconds per meter, so we convert it to km/h
                } else {
                    self.metrics.currentSpeed = 0.0
                }
            }
        }
    }
    
    // Stops the pedometer updates
    private func stopPedometer() {
        pedometer.stopUpdates()
    }
    
    // Registers a background task to keep the app running in the background
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "CyclingSession") {
            self.endBackgroundTask()
        }
    }
    
    // Ends the background task
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    // Calculates the summary of the session
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
        
        print("Session Summary:")
        print("Total Distance: \(totalDistance) km")
        print("Total Duration: \(totalDuration) seconds")
        print("Average Speed: \(averageSpeed) km/h")
        //print("Average Heart Rate: \(averageHeartRate) bpm")
        print("Total Calories: \(totalCalories) kcal")
        print("Route Coordinates: \(routeCoordinates)")        
        
        return SessionSummary(
            id: UUID(),
            date: Date(),
            totalDistance: totalDistance,
            totalDuration: totalDuration,
            averageSpeed: averageSpeed,
            averageHeartRate: averageHeartRate,
            totalCalories: totalCalories,
            segments: sessionSegments,
            routeCoordinates: routeCoordinates
        )
    }
    
    // Completes the session and saves data to HealthKit
    func completeSession() {
        let totalDistance = sessionSegments.reduce(0) { $0 + $1.distance }
        let sessionDate = Date() // Use the appropriate session date
        let endDate = Date() // Use the appropriate end date for the session
        let duration = endDate.timeIntervalSince(sessionDate)
        

        
        // Save the workout session to HealthKit
        healthKitManager.saveWorkoutSession(distance: totalDistance, duration: duration, startDate: sessionDate, endDate: endDate, metadata: [:]) { success, error in
            if success {
                print("Workout session saved to HealthKit.")
            } else if let error = error {
                print("Failed to save workout session to HealthKit: \(error.localizedDescription)")
            }
        }
        // Save the total distance to HealthKit
        healthKitManager.saveCyclingDistance(distance: totalDistance, date: sessionDate) { success, error in
            if success {
                print("Cycling distance saved to HealthKit.")
            } else if let error = error {
                print("Failed to save cycling distance to HealthKit: \(error.localizedDescription)")
            }
        }
    }
    
    // Update this method to save coordinates
    func updateRouteCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        routeCoordinates = coordinates
    }
} 
