import SwiftUI
import CoreLocation

class AppViewModel: ObservableObject {
    let locationManager = LocationManager()
    
    init() {
        requestLocationPermission()
    }
    
    private func requestLocationPermission() {
        locationManager.requestPermission()
    }
} 