import SwiftUI
import CoreLocation

struct LocationOnboardingView: View {
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            Text("Allow Location Access")
                .padding()
            
            Text("We need your location to provide better services.")
                .padding()
            
            Button(action: {
                locationManager.requestWhenInUseAuthorization()
            }) {
                Text("Allow Location")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
} 
