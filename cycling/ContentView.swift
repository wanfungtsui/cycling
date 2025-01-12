//
//  ContentView.swift
//  cycling
//
//  Created by Wanfung Tsui on 2024/12/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            mainContentView
        }
    }

    private var mainContentView: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            SessionView()
                .tabItem {
                    Label("Session", systemImage: "bicycle")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
        }
    }
}

struct OnboardingView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        TabView {
            LocationOnboardingView()
                .tabItem {
                    Text("Location Access")
                }
            
            HealthKitOnboardingView()
                .tabItem {
                    Text("HealthKit Access")
                }

            PageView(title: "Get Started", description: "Set up your profile and start cycling.", showOnboarding: $showOnboarding)
                .tabItem {
                    Text("Get Started")
                }
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }
}

struct PageView: View {
    let title: String
    let description: String
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .padding()

            Text(description)
                .font(.body)
                .padding()

            Spacer()

            if title == "Get Started" {
                Button(action: {
                    // Set onboarding as completed and transition to main content
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showOnboarding = false
                }) {
                    Text("Finish Onboarding")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
