import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    // Request authorization to read and write HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!
        ]
        
        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!
        ]
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    // Save cycling distance to HealthKit
    func saveCyclingDistance(distance: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Distance Cycling Type is unavailable"]))
            return
        }
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        let sample = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            if success {
                print("Successfully saved cycling distance to HealthKit.")
            } else if let error = error {
                print("Error saving cycling distance to HealthKit: \(error.localizedDescription)")
            }
            completion(success, error)
        }
    }
} 