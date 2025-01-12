import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    // Request authorization to read and write HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        print("Checking if HealthKit data is available...")
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKSeriesType.workoutRoute(),
            HKObjectType.workoutType()
        ]
        
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        print("Requesting HealthKit authorization...")
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("HealthKit authorization successful.")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
            completion(success, error)
        }
    }
    
    // Save cycling distance to HealthKit
    func saveCyclingDistance(distance: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        print("Preparing to save cycling distance to HealthKit...")
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
            print("Distance Cycling Type is unavailable.")
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Distance Cycling Type is unavailable"]))
            return
        }
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        let sample = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: date, end: date)
        
        print("Saving cycling distance sample to HealthKit...")
        healthStore.save(sample) { success, error in
            if success {
                print("Successfully saved cycling distance to HealthKit.")
            } else if let error = error {
                print("Error saving cycling distance to HealthKit: \(error.localizedDescription)")
            }
            completion(success, error)
        }
    }
    
    // Fetch workouts from HealthKit
    func fetchWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        print("Preparing to fetch cycling workouts from HealthKit...")
        let workoutType = HKObjectType.workoutType()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) // 180 days ago
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let cyclingPredicate = HKQuery.predicateForWorkouts(with: .cycling)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, cyclingPredicate])

        print("Fetching cycling workouts data from \(startDate!) to \(Date())")

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            if let error = error {
                print("Error fetching cycling workouts data: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let workouts = samples as? [HKWorkout] else {
                print("No cycling workouts data found.")
                completion(nil, nil)
                return
            }
            
            print("Fetched \(workouts.count) cycling workouts from HealthKit.")
            completion(workouts, nil)
        }

        healthStore.execute(query)
    }
    
    // Save session summary to HealthKit as a workout
    func saveWorkoutSession(distance: Double, duration: TimeInterval, startDate: Date, endDate: Date, metadata: [String: Any], completion: @escaping (Bool, Error?) -> Void) {
        print("Preparing to save workout session to HealthKit...")
        
        // Create a workout object with metadata
        let workout = HKWorkout(activityType: .cycling, start: startDate, end: endDate, workoutEvents: nil, totalEnergyBurned: nil, totalDistance: HKQuantity(unit: HKUnit.meter(), doubleValue: distance), metadata: metadata)
        
        // Save the workout to HealthKit
        healthStore.save(workout) { success, error in
            if success {
                print("Successfully saved workout session to HealthKit.")
            } else if let error = error {
                print("Error saving workout session to HealthKit: \(error.localizedDescription)")
            }
            completion(success, error)
        }
    }
} 
