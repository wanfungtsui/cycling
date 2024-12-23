//
//  ContentView.swift
//  cycling
//
//  Created by Wanfung Tsui on 2024/12/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            SessionView()
                .tabItem {
                    Label("Session", systemImage: "bicycle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
