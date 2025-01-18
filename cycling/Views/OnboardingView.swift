import SwiftUI
import HealthKit
import CoreLocation

// View for the onboarding process
struct OnboardingView: View {
    // Binding to control the visibility of the onboarding view
    @Binding var showOnboarding: Bool

    // State variable to track the current tab index
    @State private var currentTab = 0

    var body: some View {
        ZStack {
            Color.backgroundLight() // Set the background color
                .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen

            TabView(selection: $currentTab) {
                // First tab for location access
                VStack {
                    LocationOnboardingView()
                    Button("Next") {
                        currentTab = 1
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    .padding()
                }
                .tabItem {
                    Text("Location Access")
                }
                .tag(0)

                // Second tab for HealthKit access
                VStack {
                    HealthKitOnboardingView()
                    Button("Next") {
                        currentTab = 2
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    .padding()
                }
                .tabItem {
                    Text("HealthKit Access")
                }
                .tag(1)

                // Final tab to get started
                VStack {
                    PageView(
                        title: "Get Started", description: "Set up your profile and start cycling.",
                        showOnboarding: $showOnboarding
                    )
                }
                .tabItem {
                    Text("Get Started")
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle()) // Use a page tab view style for swiping between tabs
            .onAppear {
                // Mark onboarding as completed when the view appears
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
        }
    }
}

// View for HealthKit onboarding
struct HealthKitOnboardingView: View {
    private var healthKitManager = HealthKitManager.shared // Singleton for HealthKit interactions

    var body: some View {
        VStack {
            Text("Allow HealthKit Access")
                .font(.custom("Jersey15-Regular", size: 20))
                .foregroundColor(Color.textLight())
                .padding()
            
            Text("We need access to your health data to track your cycling sessions.")
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textLight())
                .padding()
            
            Button(action: {
                healthKitManager.requestAuthorization { success, error in
                    if success {
                        print("HealthKit authorization granted.")
                    } else if let error = error {
                        print("HealthKit authorization failed: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Allow HealthKit")
                    .bold()
            }
            .buttonStyle(OnboardingButtonStyle())
        }
    }
}

// View for location onboarding
struct LocationOnboardingView: View {
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            Text("Allow Location Access")
                .foregroundColor(Color.textLight())
                .font(.custom("Jersey15-Regular", size: 20))

                .padding()
            
            Text("We need your location to provide better services.")
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textLight())
                .padding()
            
            Button(action: {
                locationManager.requestWhenInUseAuthorization()
            }) {
                Text("Allow Location")
                    .bold()
            }
            .buttonStyle(OnboardingButtonStyle())
        }
    }
}

// View for individual onboarding pages
struct PageView: View {
    let title: String
    let description: String
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack {
            // Display the title of the page
            Text(title)
                .font(.custom("Jersey15-Regular", size: 20))
                .foregroundColor(Color.textLight())
                .padding()

            // Display the description of the page
            Text(description)
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textLight())
                .padding()


            // Show a button to finish onboarding if on the "Get Started" page
            if title == "Get Started" {
                Button(action: {
                    // Set onboarding as completed and transition to main content
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showOnboarding = false
                }) {
                    Text("Finish Onboarding")
                }
                .buttonStyle(OnboardingButtonStyle())
            }
        }
    }
}

// Custom button style for onboarding buttons
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.backgroundLight())
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 58)
            .font(.custom("Jersey15-Regular", size: 20))
            .background(Color.primaryDark())
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// Preview provider for OnboardingView
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}