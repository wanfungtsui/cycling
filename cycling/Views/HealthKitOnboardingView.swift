import SwiftUI
import HealthKit

struct HealthKitOnboardingView: View {
    private var healthKitManager = HealthKitManager.shared // Singleton for HealthKit interactions

    var body: some View {
        VStack {
            Text("Allow HealthKit Access")
                .padding()
            
            Text("We need access to your health data to track your cycling sessions.")
                .padding()
            
            Button(action: {
                requestHealthKitAuthorization()
            }) {
                Text("Allow HealthKit")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted.")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }

}

