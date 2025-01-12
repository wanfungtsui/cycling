import SwiftUI

@main
struct CyclingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.custom("Jersey15-Regular", size: 20))
                .background(Color.backgroundLight())
                .environment(\.colorScheme, .light)
        }
    }
}
