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
        
        // Convert WGS-84 to GCJ-02
        let gcj02Coordinate = CoordinateConverter.wgs84ToGcj02(newLocation.coordinate)
        let gcj02Location = CLLocation(latitude: gcj02Coordinate.latitude, longitude: gcj02Coordinate.longitude)
        
        // Update current location with GCJ-02 coordinates
        location = gcj02Location
        
        // Update speed (convert from m/s to km/h)
        speed = max(0, newLocation.speed * 3.6)
        
        // Update distance
        if let lastLocation = lastLocation {
            let incrementalDistance = gcj02Location.distance(from: lastLocation) / 1000 // Convert to kilometers
            distance += incrementalDistance
        }
        
        // Store location
        locations.append(gcj02Location)
        lastLocation = gcj02Location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
} 

struct CoordinateConverter {
    // Constants for the conversion
    private static let pi = 3.1415926535897932384626
    private static let a = 6378245.0
    private static let ee = 0.00669342162296594323

    // Convert WGS-84 to GCJ-02
    static func wgs84ToGcj02(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if isOutOfChina(coordinate) {
            return coordinate
        }
        
        var dLat = transformLat(x: coordinate.longitude - 105.0, y: coordinate.latitude - 35.0)
        var dLon = transformLon(x: coordinate.longitude - 105.0, y: coordinate.latitude - 35.0)
        let radLat = coordinate.latitude / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        
        let mgLat = coordinate.latitude + dLat
        let mgLon = coordinate.longitude + dLon
        return CLLocationCoordinate2D(latitude: mgLat, longitude: mgLon)
    }

    // Check if the coordinate is outside China
    private static func isOutOfChina(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if coordinate.longitude < 72.004 || coordinate.longitude > 137.8347 {
            return true
        }
        if coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271 {
            return true
        }
        return false
    }

    // Transform latitude
    private static func transformLat(x: Double, y: Double) -> Double {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0
        return ret
    }

    // Transform longitude
    private static func transformLon(x: Double, y: Double) -> Double {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0
        return ret
    }
}