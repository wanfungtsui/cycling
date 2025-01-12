import Foundation
import HealthKit
import CoreLocation

class SessionStorage {
    private let healthKitManager = HealthKitManager.shared
    private var summaries: [SessionSummary] = []
    private let key = "cycling_sessions"
    private let healthStore = HKHealthStore()

    // Fetch and store workouts as session summaries
    func fetchAndStoreWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        print("Starting to fetch and store workouts...")
        healthKitManager.fetchWorkouts { [weak self] workouts, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let workouts = workouts else {
                print("No workouts to process.")
                completion(false, nil)
                return
            }
            
            print("Transforming workouts into session summaries...")
            var sessionSummaries: [SessionSummary] = []
            let dispatchGroup = DispatchGroup()
            
            for workout in workouts {
                dispatchGroup.enter()
                
                // Fetch route coordinates asynchronously
                self?.fetchRouteCoordinates(for: workout) { routeCoordinates in
                    let totalDistanceInMeters = workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
                    let totalDistanceInKilometers = totalDistanceInMeters / 1000.0 // Convert meters to kilometers
                    let totalDuration = workout.duration
                    let averageSpeed = totalDistanceInKilometers / totalDuration
                    let averageHeartRate = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0.0
                    let totalCalories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0
                    
                    //print("Creating session summary for workout on \(workout.startDate)")
                    let sessionSummary = SessionSummary(
                        date: workout.startDate,
                        totalDistance: totalDistanceInKilometers,
                        totalDuration: totalDuration,
                        averageSpeed: averageSpeed,
                        averageHeartRate: Int(averageHeartRate),
                        totalCalories: totalCalories,
                        segments: [], // Assuming segments are not available from workout data
                        routeCoordinates: routeCoordinates
                    )
                    
                    sessionSummaries.append(sessionSummary)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self?.summaries = sessionSummaries
                self?.summaries.forEach { summary in
                    self?.saveSummary(summary)
                }
                completion(true, nil)
            }
        }
    }
    
    // Fetch route coordinates for a workout
    private func fetchRouteCoordinates(for workout: HKWorkout, completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        print("Fetching route coordinates for workout...")
        var coordinates: [CLLocationCoordinate2D] = []
        
        let routePredicate = HKQuery.predicateForObjects(from: workout)
        let routeQuery = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(), predicate: routePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let routes = results as? [HKWorkoutRoute], error == nil else {
                print("Error fetching workout routes: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for route in routes {
                dispatchGroup.enter()
                let routeQuery = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                    guard let locations = locationsOrNil else {
                        print("Error fetching route locations: \(errorOrNil?.localizedDescription ?? "Unknown error")")
                        dispatchGroup.leave()
                        return
                    }
                    
                    coordinates.append(contentsOf: locations.map { $0.coordinate })
                    
                    if done {
                        dispatchGroup.leave()
                    }
                }
                self.healthStore.execute(routeQuery)
            }
            
            dispatchGroup.notify(queue: .main) {
                //print("Finished fetching route coordinates.")
                completion(coordinates)
            }
        }
        
        healthStore.execute(routeQuery)
        
    }
    
    // Save session summaries to local storage
    func saveSummary(_ summary: SessionSummary) {
        var summaries = getAllSessions()
        summaries.removeAll { $0.date == summary.date }

        summaries.append(summary)
        if let encoded = try? JSONEncoder().encode(summaries) {
            UserDefaults.standard.set(encoded, forKey: key)
            //print("Session summaries saved to local storage.")
        } else {
            print("Failed to encode session summaries.")
        }
    }
    
    // Retrieve all session summaries from local storage
    func getAllSessions() -> [SessionSummary] {
        //print("Retrieving all session summaries from local storage...")
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SessionSummary].self, from: data) {
            //print("Successfully retrieved session summaries.")
            return decoded
        }
        print("No session summaries found in local storage.")
        return []
    }
}
