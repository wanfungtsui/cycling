//
//  ContentView.swift
//  cycling
//
//  Created by Wanfung Tsui on 2024/12/23.
//

import SwiftUI

// Main view of the application
struct ContentView: View {
    // State variable to track if onboarding should be shown
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(
        forKey: "hasCompletedOnboarding")
    // Initializer to customize the appearance of the navigation bar
    init() {
        // Call function to customize the navigation bar appearance
        NavigationBarCustomizer.customizeNavigationBar()
    }
    var body: some View {
        // Conditionally show OnboardingView or DashboardView based on showOnboarding state
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            DashboardView()
        }
    }

}

// Preview provider for SwiftUI previews
#Preview {
    ContentView()
}
