import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var speed: Double = 0
    @Published var distance: Double = 0
    private var locations: [CLLocation] = []
    
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.activityType = .fitness
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        locations.removeAll()
        distance = 0
        lastLocation = nil
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func resetTracking() {
        locations.removeAll()
        distance = 0
        speed = 0
        lastLocation = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let newLocation = newLocations.last else { return }
        
        // Update current location
        location = newLocation
        
        // Update speed (convert from m/s to km/h)
        speed = max(0, newLocation.speed * 3.6)
        
        // Update distance
        if let lastLocation = lastLocation {
            let incrementalDistance = newLocation.distance(from: lastLocation) / 1000 // Convert to kilometers
            distance += incrementalDistance
        }
        
        // Store location
        locations.append(newLocation)
        lastLocation = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
} 